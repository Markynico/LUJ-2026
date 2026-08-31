extends Node

const RUTA_ARCHIVO : String = "user://progreso.cfg"
const CARPETA_RELIQUIAS : String = "res://scripts/resources/reliquias"
const CARPETA_COMIDAS : String = "res://scripts/resources"
const SECCION_CONTADORES : String = "contadores"
const SECCION_DESBLOQUEOS : String = "desbloqueos"

var contadores : Dictionary = {
	"runs_jugadas": 0,
	"runs_ganadas": 0,
	"niveles_ganados": 0,
	"niveles_perdidos": 0,
	"ovillos_rotos": 0,
	"bolas_disparadas": 0,
	"monedas_conseguidas": 0,
	"items_comprados": 0,
	"reliquias_adquiridas": 0,
	"curas_compradas": 0,
	"reliquias_de_loot": 0,
}
var ovillos_rotos_por_tipo : Dictionary = {}
var runs_ganadas_por_rango : Dictionary = {}
var reliquias_desbloqueadas : Array[String] = []
var recursos_con_condicion : Array[Resource] = []
var cache_condiciones_lista : bool = false
var snapshot_run : Array[String] = []


func _ready() -> void:
	cargar()


func acumular_run() -> void:
	var rango : int
	contadores["runs_jugadas"] += 1
	if EstadisticasRun.gano_la_run:
		contadores["runs_ganadas"] += 1
		if EstadisticasRun.dificultad:
			rango = EstadisticasRun.dificultad.rango
			runs_ganadas_por_rango[rango] = runs_ganadas_por_rango.get(rango, 0) + 1
	contadores["niveles_ganados"] += EstadisticasRun.niveles_ganados
	contadores["niveles_perdidos"] += EstadisticasRun.niveles_perdidos
	contadores["ovillos_rotos"] += EstadisticasRun.ovillos_rotos
	contadores["bolas_disparadas"] += EstadisticasRun.bolas_disparadas
	contadores["monedas_conseguidas"] += EstadisticasRun.monedas_conseguidas
	contadores["items_comprados"] += EstadisticasRun.comidas_compradas + EstadisticasRun.reliquias_adquiridas.size()
	contadores["reliquias_adquiridas"] += EstadisticasRun.reliquias_adquiridas.size()
	contadores["curas_compradas"] += EstadisticasRun.curas_compradas
	contadores["reliquias_de_loot"] += EstadisticasRun.reliquias_de_loot
	for clave in EstadisticasRun.ovillos_rotos_por_tipo:
		ovillos_rotos_por_tipo[clave] = ovillos_rotos_por_tipo.get(clave, 0) + EstadisticasRun.ovillos_rotos_por_tipo[clave]
	revisar_desbloqueos()
	guardar()


func cargar_recursos_con_condicion() -> void:
	var recurso : Resource
	if cache_condiciones_lista:
		return
	cache_condiciones_lista = true
	for carpeta in [CARPETA_RELIQUIAS, CARPETA_COMIDAS]:
		for archivo in DirAccess.get_files_at(carpeta):
			if archivo.get_extension() != "tres":
				continue
			recurso = load(carpeta.path_join(archivo))
			if not (recurso is Reliquia or recurso is PelotitaBase):
				continue
			if recurso.condicion_desbloqueo.is_empty() or recurso.condicion_desbloqueo == "Ninguna":
				continue
			recursos_con_condicion.append(recurso)


func empezar_run() -> void:
	cargar_recursos_con_condicion()
	for recurso in recursos_con_condicion:
		esta_desbloqueada(recurso)
	snapshot_run = reliquias_desbloqueadas.duplicate()


func revisar_desbloqueos() -> void:
	var ya_desbloqueadas : Array[String] = reliquias_desbloqueadas.duplicate()
	cargar_recursos_con_condicion()
	for recurso in recursos_con_condicion:
		if not ya_desbloqueadas.has(recurso.resource_path) and esta_desbloqueada(recurso):
			Notificaciones.mostrar_desbloqueo(recurso)


func revisar_desbloqueos_en_vivo() -> void:
	var hubo_nuevas : bool = false
	if not EstadisticasRun.run_activa:
		return
	for recurso in recursos_con_condicion:
		if reliquias_desbloqueadas.has(recurso.resource_path):
			continue
		if valor_condicion(recurso) + parcial_condicion(recurso) >= recurso.cantidad_desbloqueo:
			reliquias_desbloqueadas.append(recurso.resource_path)
			Notificaciones.mostrar_desbloqueo(recurso)
			hubo_nuevas = true
	if hubo_nuevas:
		guardar()


func parcial_condicion(recurso : Resource) -> int:
	match recurso.condicion_desbloqueo:
		"niveles_ganados":
			return EstadisticasRun.niveles_ganados
		"niveles_perdidos":
			return EstadisticasRun.niveles_perdidos
		"ovillos_rotos":
			return EstadisticasRun.ovillos_rotos
		"ovillos_rotos_de_tipo":
			if not recurso.ovillo_objetivo:
				return 0
			return EstadisticasRun.ovillos_rotos_por_tipo.get(EstadisticasRun.clave_de_ovillo(recurso.ovillo_objetivo), 0)
		"bolas_disparadas":
			return EstadisticasRun.bolas_disparadas
		"monedas_conseguidas":
			return EstadisticasRun.monedas_conseguidas
		"items_comprados":
			return EstadisticasRun.comidas_compradas + EstadisticasRun.reliquias_adquiridas.size()
		"reliquias_adquiridas":
			return EstadisticasRun.reliquias_adquiridas.size()
		"curas_compradas":
			return EstadisticasRun.curas_compradas
		"reliquias_de_loot":
			return EstadisticasRun.reliquias_de_loot
	return 0


func valor_de(contador : String) -> int:
	return contadores.get(contador, 0)


func esta_desbloqueada(reliquia : Resource) -> bool:
	if reliquia.condicion_desbloqueo.is_empty() or reliquia.condicion_desbloqueo == "Ninguna":
		return true
	if reliquias_desbloqueadas.has(reliquia.resource_path):
		return true
	if valor_condicion(reliquia) >= reliquia.cantidad_desbloqueo:
		reliquias_desbloqueadas.append(reliquia.resource_path)
		return true
	return false


const TEXTOS_CONDICION : Dictionary = {
	"runs_jugadas": "Jugá %d runs",
	"runs_ganadas": "Ganá %d runs",
	"niveles_ganados": "Ganá %d niveles",
	"niveles_perdidos": "Perdé %d niveles",
	"ovillos_rotos": "Rompé %d ovillos",
	"ovillos_rotos_de_tipo": "Rompé %d ovillos %s",
	"bolas_disparadas": "Dispará %d bolas de pelo",
	"monedas_conseguidas": "Conseguí %d monedas",
	"items_comprados": "Comprá %d items",
	"reliquias_adquiridas": "Adquirí %d reliquias",
	"curas_compradas": "Curate %d veces en la tienda",
	"reliquias_de_loot": "Agarrá %d reliquias del loot",
	"runs_ganadas_en_dificultad": "Ganá %d runs en %s o más",
}


func descripcion_condicion(reliquia : Resource) -> String:
	var plantilla : String = TEXTOS_CONDICION.get(reliquia.condicion_desbloqueo, "")
	if plantilla.is_empty():
		return ""
	if reliquia.condicion_desbloqueo == "ovillos_rotos_de_tipo":
		return plantilla % [reliquia.cantidad_desbloqueo, nombre_corto_ovillo(reliquia.ovillo_objetivo)]
	if reliquia.condicion_desbloqueo == "runs_ganadas_en_dificultad":
		return plantilla % [reliquia.cantidad_desbloqueo, reliquia.dificultad_objetivo.nombre if reliquia.dificultad_objetivo else "?"]
	return plantilla % reliquia.cantidad_desbloqueo


func nombre_corto_ovillo(tipo : OvilloBase) -> String:
	var nombre : String = tipo.nombre if tipo else "?"
	for prefijo in ["ovillo de ", "ovillo "]:
		if nombre.to_lower().begins_with(prefijo):
			return nombre.substr(prefijo.length())
	return nombre


func valor_condicion(reliquia : Resource) -> int:
	if reliquia.condicion_desbloqueo == "ovillos_rotos_de_tipo":
		if not reliquia.ovillo_objetivo:
			return 0
		return ovillos_rotos_por_tipo.get(EstadisticasRun.clave_de_ovillo(reliquia.ovillo_objetivo), 0)
	if reliquia.condicion_desbloqueo == "runs_ganadas_en_dificultad":
		return runs_ganadas_desde(reliquia.dificultad_objetivo.rango if reliquia.dificultad_objetivo else 0)
	return valor_de(reliquia.condicion_desbloqueo)


func runs_ganadas_desde(rango_minimo : int) -> int:
	var total : int = 0
	for rango in runs_ganadas_por_rango:
		if rango >= rango_minimo:
			total += runs_ganadas_por_rango[rango]
	return total


func filtrar_desbloqueadas(reliquias : Array) -> Array:
	if EstadisticasRun.run_activa:
		return reliquias.filter(func(reliquia : Resource) -> bool: return reliquia and disponible_en_run(reliquia))
	return reliquias.filter(func(reliquia : Resource) -> bool: return reliquia and esta_desbloqueada(reliquia))


func disponible_en_run(recurso : Resource) -> bool:
	if recurso.condicion_desbloqueo.is_empty() or recurso.condicion_desbloqueo == "Ninguna":
		return true
	return snapshot_run.has(recurso.resource_path)


func guardar() -> void:
	var archivo : ConfigFile = ConfigFile.new()
	for clave in contadores:
		archivo.set_value(SECCION_CONTADORES, clave, contadores[clave])
	for clave in ovillos_rotos_por_tipo:
		archivo.set_value("ovillos_rotos_por_tipo", clave, ovillos_rotos_por_tipo[clave])
	for rango in runs_ganadas_por_rango:
		archivo.set_value("runs_ganadas_por_rango", str(rango), runs_ganadas_por_rango[rango])
	archivo.set_value(SECCION_DESBLOQUEOS, "reliquias", reliquias_desbloqueadas)
	archivo.save(RUTA_ARCHIVO)


func cargar() -> void:
	var archivo : ConfigFile = ConfigFile.new()
	if archivo.load(RUTA_ARCHIVO) != OK:
		return
	for clave in contadores:
		contadores[clave] = archivo.get_value(SECCION_CONTADORES, clave, 0)
	ovillos_rotos_por_tipo.clear()
	if archivo.has_section("ovillos_rotos_por_tipo"):
		for clave in archivo.get_section_keys("ovillos_rotos_por_tipo"):
			ovillos_rotos_por_tipo[clave] = archivo.get_value("ovillos_rotos_por_tipo", clave, 0)
	runs_ganadas_por_rango.clear()
	if archivo.has_section("runs_ganadas_por_rango"):
		for clave in archivo.get_section_keys("runs_ganadas_por_rango"):
			runs_ganadas_por_rango[int(clave)] = archivo.get_value("runs_ganadas_por_rango", clave, 0)
	reliquias_desbloqueadas.assign(archivo.get_value(SECCION_DESBLOQUEOS, "reliquias", []))


func resetear() -> void:
	for clave in contadores:
		contadores[clave] = 0
	ovillos_rotos_por_tipo.clear()
	runs_ganadas_por_rango.clear()
	reliquias_desbloqueadas.clear()
	guardar()
