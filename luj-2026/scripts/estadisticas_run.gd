extends Node

var inicio_run_msec : int = 0
var run_activa : bool = false
var puntos_totales : int = 0
var monedas_conseguidas : int = 0
var monedas_gastadas : int = 0
var reliquias_adquiridas : Array[Reliquia] = []
var comidas_compradas : int = 0
var niveles_ganados : int = 0
var niveles_perdidos : int = 0
var mejor_puntaje_nivel : int = 0
var ovillos_rotos : int = 0
var ovillos_rotos_por_tipo : Dictionary = {}
var bolas_disparadas : int = 0
var curas_compradas : int = 0
var reliquias_de_loot : int = 0
var dificultad : DificultadRun
var gano_la_run : bool = false


func _ready() -> void:
	ReliquiasManager.reliquia_obtenida.connect(al_obtener_reliquia)


func empezar_run() -> void:
	inicio_run_msec = Time.get_ticks_msec()
	run_activa = true
	puntos_totales = 0
	monedas_conseguidas = 0
	monedas_gastadas = 0
	reliquias_adquiridas.clear()
	comidas_compradas = 0
	niveles_ganados = 0
	niveles_perdidos = 0
	mejor_puntaje_nivel = 0
	ovillos_rotos = 0
	ovillos_rotos_por_tipo.clear()
	bolas_disparadas = 0
	curas_compradas = 0
	reliquias_de_loot = 0
	dificultad = GameManager.dificultad_actual
	gano_la_run = false


func terminar_run(gano : bool) -> void:
	if not run_activa:
		return
	run_activa = false
	gano_la_run = gano
	Progreso.acumular_run()


func duracion_segundos() -> float:
	return (Time.get_ticks_msec() - inicio_run_msec) / 1000.0


func registrar_nivel(puntos : int, gano : bool) -> void:
	if not run_activa:
		return
	puntos_totales += puntos
	mejor_puntaje_nivel = maxi(mejor_puntaje_nivel, puntos)
	if gano:
		niveles_ganados += 1
	else:
		niveles_perdidos += 1


func registrar_monedas(cambio : int) -> void:
	if not run_activa:
		return
	if cambio > 0:
		monedas_conseguidas += cambio
	else:
		monedas_gastadas -= cambio


func registrar_comida_comprada() -> void:
	if run_activa:
		comidas_compradas += 1


func registrar_ovillo_roto(tipo : OvilloBase = null) -> void:
	var clave : String
	if not run_activa:
		return
	ovillos_rotos += 1
	if tipo:
		clave = clave_de_ovillo(tipo)
		ovillos_rotos_por_tipo[clave] = ovillos_rotos_por_tipo.get(clave, 0) + 1


static func clave_de_ovillo(tipo : OvilloBase) -> String:
	return tipo.resource_path.get_file().get_basename()


func registrar_bola_disparada() -> void:
	if run_activa:
		bolas_disparadas += 1


func registrar_cura_comprada() -> void:
	if run_activa:
		curas_compradas += 1


func registrar_reliquia_loot() -> void:
	if run_activa:
		reliquias_de_loot += 1


func al_obtener_reliquia(reliquia : Reliquia) -> void:
	if run_activa:
		reliquias_adquiridas.append(reliquia)
