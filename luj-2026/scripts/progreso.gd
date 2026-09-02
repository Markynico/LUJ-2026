extends Node

const RUTA_ARCHIVO : String = "user://progreso.cfg"
const RUTA_RESPALDO : String = "user://progreso.cfg.bak"
const CARPETA_RELIQUIAS : String = "res://scripts/resources/reliquias"
const CARPETA_COMIDAS : String = "res://scripts/resources"
const SECCION_ARCHIVO : String = "archivo"
const SECCION_CONTADORES : String = "contadores"
const SECCION_DESBLOQUEOS : String = "desbloqueos"
const VERSION_ARCHIVO : int = 2
const SECCION_RUN_EN_CURSO : String = "run_en_curso"
const SEGUNDOS_ENTRE_GUARDADOS : float = 3.0
const SEPARADOR_CONDICIONES : String = ", "
const SEPARADOR_ULTIMA_CONDICION : String = " y "

const TEXTOS_CONDICION : Dictionary = {
	"runs_jugadas": "Jugá %d runs",
	"runs_ganadas": "Ganá %d runs",
	"niveles_ganados": "Ganá %d niveles",
	"niveles_perdidos": "Perdé %d niveles",
	"niveles_limpios": "Limpiá %d niveles al 100%%",
	"ovillos_rotos": "Rompé %d ovillos",
	"ovillos_rotos_de_tipo": "Rompé %d %s",
	"bolas_disparadas": "Dispará %d bolas de pelo",
	"monedas_conseguidas": "Conseguí %d {monedas:icono}",
	"monedas_gastadas": "Gastá %d {monedas:icono}",
	"items_comprados": "Comprá %d items",
	"reliquias_adquiridas": "Adquirí %d reliquias",
	"curas_compradas": "Curate %d veces en la tienda",
	"reliquias_de_loot": "Agarrá %d reliquias del loot",
	"runs_ganadas_en_dificultad": "Ganá %d runs en %s o más",
	"reliquia_desbloqueada": "Desbloqueá %s",
}

var contadores : Dictionary = {
	"runs_jugadas": 0,
	"runs_ganadas": 0,
	"niveles_ganados": 0,
	"niveles_perdidos": 0,
	"niveles_limpios": 0,
	"ovillos_rotos": 0,
	"bolas_disparadas": 0,
	"monedas_conseguidas": 0,
	"monedas_gastadas": 0,
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
var archivo_dañado : bool = false
var revisando : Array[String] = []
var guardado_pendiente : bool = false
var tiempo_desde_guardado : float = 0.0


func _ready() -> void:
	cargar()


func _process(delta : float) -> void:
	tiempo_desde_guardado += delta
	if guardado_pendiente and tiempo_desde_guardado >= SEGUNDOS_ENTRE_GUARDADOS:
		guardar()


func _notification(que : int) -> void:
	if que == NOTIFICATION_WM_CLOSE_REQUEST and guardado_pendiente:
		guardar()


func pedir_guardado() -> void:
	guardado_pendiente = true


func estadisticas_de_run() -> Dictionary:
	return {
		"niveles_ganados": EstadisticasRun.niveles_ganados,
		"niveles_perdidos": EstadisticasRun.niveles_perdidos,
		"niveles_limpios": EstadisticasRun.niveles_limpios,
		"ovillos_rotos": EstadisticasRun.ovillos_rotos,
		"bolas_disparadas": EstadisticasRun.bolas_disparadas,
		"monedas_conseguidas": EstadisticasRun.monedas_conseguidas,
		"monedas_gastadas": EstadisticasRun.monedas_gastadas,
		"items_comprados": EstadisticasRun.comidas_compradas + EstadisticasRun.reliquias_adquiridas.size(),
		"reliquias_adquiridas": EstadisticasRun.reliquias_adquiridas.size(),
		"curas_compradas": EstadisticasRun.curas_compradas,
		"reliquias_de_loot": EstadisticasRun.reliquias_de_loot,
		"ovillos_rotos_por_tipo": EstadisticasRun.ovillos_rotos_por_tipo.duplicate(),
	}


func sumar_estadisticas(datos : Dictionary) -> void:
	var por_tipo : Dictionary = datos.get("ovillos_rotos_por_tipo", {})
	for clave in datos:
		if contadores.has(clave):
			contadores[clave] += int(datos[clave])
	for clave in por_tipo:
		ovillos_rotos_por_tipo[clave] = ovillos_rotos_por_tipo.get(clave, 0) + int(por_tipo[clave])


func acumular_run() -> void:
	var rango : int
	contadores["runs_jugadas"] += 1
	if EstadisticasRun.gano_la_run:
		contadores["runs_ganadas"] += 1
		if EstadisticasRun.dificultad:
			rango = EstadisticasRun.dificultad.rango
			runs_ganadas_por_rango[rango] = runs_ganadas_por_rango.get(rango, 0) + 1
	sumar_estadisticas(estadisticas_de_run())
	revisar_desbloqueos()
	guardar()


func tiene_condiciones(recurso : Resource) -> bool:
	return "condiciones_desbloqueo" in recurso and not condiciones_de(recurso).is_empty()


func condiciones_de(recurso : Resource) -> Array[CondicionDesbloqueo]:
	var lista : Array[CondicionDesbloqueo] = []
	if not "condiciones_desbloqueo" in recurso or recurso.condiciones_desbloqueo == null:
		return lista
	for condicion in recurso.condiciones_desbloqueo:
		if condicion:
			lista.append(condicion)
	return lista


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
			if tiene_condiciones(recurso):
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
	pedir_guardado()
	for recurso in recursos_con_condicion:
		if reliquias_desbloqueadas.has(recurso.resource_path):
			continue
		if cumple_todas(recurso, true):
			reliquias_desbloqueadas.append(recurso.resource_path)
			Notificaciones.mostrar_desbloqueo(recurso)
			hubo_nuevas = true
	if hubo_nuevas:
		guardar()


func cumple_todas(recurso : Resource, con_parcial : bool) -> bool:
	var condiciones : Array[CondicionDesbloqueo] = condiciones_de(recurso)
	if condiciones.is_empty():
		return true
	for condicion in condiciones:
		if not cumple(condicion, con_parcial):
			return false
	return true


func cumple(condicion : CondicionDesbloqueo, con_parcial : bool) -> bool:
	var valor : int = valor_condicion(condicion)
	if con_parcial:
		valor += parcial_condicion(condicion)
	return valor >= condicion.cantidad


func parcial_condicion(condicion : CondicionDesbloqueo) -> int:
	match condicion.contador:
		"niveles_ganados":
			return EstadisticasRun.niveles_ganados
		"niveles_perdidos":
			return EstadisticasRun.niveles_perdidos
		"niveles_limpios":
			return EstadisticasRun.niveles_limpios
		"ovillos_rotos":
			return EstadisticasRun.ovillos_rotos
		"ovillos_rotos_de_tipo":
			if not condicion.ovillo_objetivo:
				return 0
			return EstadisticasRun.ovillos_rotos_por_tipo.get(EstadisticasRun.clave_de_ovillo(condicion.ovillo_objetivo), 0)
		"bolas_disparadas":
			return EstadisticasRun.bolas_disparadas
		"monedas_conseguidas":
			return EstadisticasRun.monedas_conseguidas
		"monedas_gastadas":
			return EstadisticasRun.monedas_gastadas
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


func valor_condicion(condicion : CondicionDesbloqueo) -> int:
	if condicion.contador == "ovillos_rotos_de_tipo":
		if not condicion.ovillo_objetivo:
			return 0
		return ovillos_rotos_por_tipo.get(EstadisticasRun.clave_de_ovillo(condicion.ovillo_objetivo), 0)
	if condicion.contador == "runs_ganadas_en_dificultad":
		return runs_ganadas_desde(condicion.dificultad_objetivo.rango if condicion.dificultad_objetivo else 0)
	if condicion.contador == "reliquia_desbloqueada":
		if not condicion.reliquia_objetivo or revisando.has(condicion.reliquia_objetivo.resource_path):
			return 0
		return 1 if esta_desbloqueada(condicion.reliquia_objetivo) else 0
	return valor_de(condicion.contador)


func esta_desbloqueada(recurso : Resource) -> bool:
	var cumplida : bool
	if not tiene_condiciones(recurso):
		return true
	if reliquias_desbloqueadas.has(recurso.resource_path):
		return true
	revisando.append(recurso.resource_path)
	cumplida = cumple_todas(recurso, false)
	revisando.erase(recurso.resource_path)
	if cumplida:
		reliquias_desbloqueadas.append(recurso.resource_path)
		return true
	return false


func descripcion_condiciones(recurso : Resource) -> String:
	var partes : PackedStringArray = PackedStringArray()
	for condicion in condiciones_de(recurso):
		partes.append(descripcion_condicion(condicion))
	return unir_naturalmente(partes)


func contadores_condiciones(recurso : Resource) -> String:
	var partes : PackedStringArray = PackedStringArray()
	for condicion in condiciones_de(recurso):
		partes.append("%d/%d" % [mini(valor_condicion(condicion) + (parcial_condicion(condicion) if EstadisticasRun.run_activa else 0), condicion.cantidad), condicion.cantidad])
	return unir_naturalmente(partes)


func unir_naturalmente(partes : PackedStringArray) -> String:
	var ultima : String
	if partes.size() <= 1:
		return "".join(partes)
	ultima = partes[partes.size() - 1]
	partes.resize(partes.size() - 1)
	return SEPARADOR_CONDICIONES.join(partes) + SEPARADOR_ULTIMA_CONDICION + ultima


func descripcion_condicion(condicion : CondicionDesbloqueo) -> String:
	var plantilla : String = TEXTOS_CONDICION.get(condicion.contador, "")
	if plantilla.is_empty():
		return ""
	if condicion.contador == "ovillos_rotos_de_tipo":
		return plantilla % [condicion.cantidad, placeholder_ovillo(condicion.ovillo_objetivo)]
	if condicion.contador == "runs_ganadas_en_dificultad":
		return plantilla % [condicion.cantidad, placeholder_dificultad(condicion.dificultad_objetivo)]
	if condicion.contador == "reliquia_desbloqueada":
		return plantilla % (condicion.reliquia_objetivo.nombre if condicion.reliquia_objetivo and "nombre" in condicion.reliquia_objetivo else "?")
	return plantilla % condicion.cantidad


func placeholder_dificultad(dificultad : DificultadRun) -> String:
	var claves : PackedStringArray = PackedStringArray(["facil", "media", "dificil"])
	if not dificultad:
		return "?"
	if dificultad.rango >= 0 and dificultad.rango < claves.size() and Resaltador.PALABRAS.has(claves[dificultad.rango]):
		return "{%s:icono}" % claves[dificultad.rango]
	return dificultad.nombre


func placeholder_ovillo(tipo : OvilloBase) -> String:
	var clave : String
	if not tipo:
		return "?"
	clave = EstadisticasRun.clave_de_ovillo(tipo).trim_prefix("ovillo_").trim_suffix("_final")
	if Resaltador.PALABRAS.has("ovillo_" + clave):
		return "{ovillo_%s:icono}" % clave
	if Resaltador.PALABRAS.has(clave):
		return "{%s:icono}" % clave
	return "ovillos " + nombre_corto_ovillo(tipo)


func nombre_corto_ovillo(tipo : OvilloBase) -> String:
	var nombre : String = tipo.nombre if tipo else "?"
	for prefijo in ["ovillo de ", "ovillo "]:
		if nombre.to_lower().begins_with(prefijo):
			return nombre.substr(prefijo.length())
	return nombre


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
	if not tiene_condiciones(recurso):
		return true
	return snapshot_run.has(recurso.resource_path)


func guardar() -> void:
	var archivo : ConfigFile = ConfigFile.new()
	if archivo_dañado:
		push_warning("El progreso no se guarda porque el archivo original no se pudo leer, revisa " + RUTA_RESPALDO)
		return
	archivo.set_value(SECCION_ARCHIVO, "version", VERSION_ARCHIVO)
	for clave in contadores:
		archivo.set_value(SECCION_CONTADORES, clave, contadores[clave])
	for clave in ovillos_rotos_por_tipo:
		archivo.set_value("ovillos_rotos_por_tipo", clave, ovillos_rotos_por_tipo[clave])
	for rango in runs_ganadas_por_rango:
		archivo.set_value("runs_ganadas_por_rango", str(rango), runs_ganadas_por_rango[rango])
	archivo.set_value(SECCION_DESBLOQUEOS, "reliquias", reliquias_desbloqueadas)
	if EstadisticasRun.run_activa:
		archivo.set_value(SECCION_RUN_EN_CURSO, "estadisticas", estadisticas_de_run())
	archivo.save(RUTA_ARCHIVO)
	guardado_pendiente = false
	tiempo_desde_guardado = 0.0


func cargar() -> void:
	var archivo : ConfigFile = ConfigFile.new()
	if not FileAccess.file_exists(RUTA_ARCHIVO):
		return
	if archivo.load(RUTA_ARCHIVO) != OK:
		archivo_dañado = true
		DirAccess.copy_absolute(RUTA_ARCHIVO, RUTA_RESPALDO)
		push_warning("No se pudo leer el progreso, se guardo una copia en " + RUTA_RESPALDO)
		return
	if archivo.has_section(SECCION_CONTADORES):
		for clave in archivo.get_section_keys(SECCION_CONTADORES):
			contadores[clave] = int(archivo.get_value(SECCION_CONTADORES, clave, 0))
	ovillos_rotos_por_tipo.clear()
	if archivo.has_section("ovillos_rotos_por_tipo"):
		for clave in archivo.get_section_keys("ovillos_rotos_por_tipo"):
			ovillos_rotos_por_tipo[clave] = archivo.get_value("ovillos_rotos_por_tipo", clave, 0)
	runs_ganadas_por_rango.clear()
	if archivo.has_section("runs_ganadas_por_rango"):
		for clave in archivo.get_section_keys("runs_ganadas_por_rango"):
			runs_ganadas_por_rango[int(clave)] = archivo.get_value("runs_ganadas_por_rango", clave, 0)
	reliquias_desbloqueadas.assign(archivo.get_value(SECCION_DESBLOQUEOS, "reliquias", []))
	if archivo.has_section(SECCION_RUN_EN_CURSO):
		sumar_estadisticas(archivo.get_value(SECCION_RUN_EN_CURSO, "estadisticas", {}))
		guardar()


func resetear() -> void:
	for clave in contadores:
		contadores[clave] = 0
	ovillos_rotos_por_tipo.clear()
	runs_ganadas_por_rango.clear()
	reliquias_desbloqueadas.clear()
	archivo_dañado = false
	guardar()
