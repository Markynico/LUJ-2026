@icon("res://iconos_custom/gobot.svg")
class_name GameManager
extends Node

signal bola_usada(bolas_restantes : int)
signal gato_lanza_bola
signal lanzar_gato
signal vidas_cambiadas(vidas_actuales : int, vidas_maximas : int)
signal puntos_actualizados(obtenidos : int, requeridos : int, total : int, porcentaje_actual : float)
signal meta_alcanzada(es_meta : bool)
signal nivel_completado(exito : bool)
signal game_over
signal sala_pedida(tipo_sala : TipoDeSala.Tipo)
signal nivel_reiniciado

enum EstadoDeJuego {
	ESPERANDO, # Al iniciar el nivel y elegir los poderes
	TIENDA, # Mientras se compra
	LANZANDO_BOLAS,
	ESPERANDO_BOLA, #aver si soluciona el bug, para q espere hasta q termine la animacion y recien ahi tire y descuente la bola
	LANZANDO_GATO,
	NIVEL_COMPLETADO,
	GAME_OVER,
	SELECCIONANDO_COMIDAS
}

static var instancia_actual: GameManager
static var vidas_guardadas: int = 3
static var vidas_inicializadas: bool = false
static var dificultad_actual : DificultadRun
static var niveles_jugados : int = 0
static var niveles_ganados_run : int = 0

@export var gato : Gato
@export var cargador_nivel : CargadorDeNivel
@export var selector_niveles : SelectorDeNiveles
##escena del menu principal a la que vuelve el game over
@export_file("*.tscn") var escena_menu : String = "uid://c30ry4xehty4"
##pantalla de stats que se muestra al terminar la run
@export_file("*.tscn") var escena_stats : String = "res://escenas/pantalla_stats.tscn"
@export var bolas_maximas : int = 4
@export var vidas_maximas : int = 3
@export_range(0.1, 1.0, 0.05) var porcentaje_ovillos_requerido : float = 0.30
##reliquias con las que arranca la run, para probar
@export var reliquias_iniciales : Array[Reliquia] = []
##monedas con las que arranca la run
@export var monedas_iniciales : int = 0
##dificultad que se usa si no se eligio ninguna en el menu
@export var dificultad_default : DificultadRun = preload("res://scripts/resources/dificultades/dificultad_facil.tres")

@export_group("Rareza")
##probabilidad en porcentaje de rareza comun
@export var probabilidad_comun : float = 60.0
##probabilidad en porcentaje de rareza rara
@export var probabilidad_raro : float = 25.0
##probabilidad en porcentaje de rareza epica
@export var probabilidad_epico : float = 10.0
##probabilidad en porcentaje de rareza legendaria
@export var probabilidad_legendario : float = 5.0
@export_group("")


var bolas_restantes : int = 0:
	set(valor):
		bolas_restantes = valor
		bola_usada.emit(bolas_restantes)
var vidas_actuales : int = 3
var estado_actual : EstadoDeJuego = EstadoDeJuego.ESPERANDO

var puntos_totales : int = 0
var puntos_obtenidos : int = 0
var puntos_requeridos : int = 0
var es_meta_cumplida : bool = false
var ovillos_registrados : Array[Ovillo] = []
var finalizando : bool = false

func _enter_tree() -> void:
	instancia_actual = self

func _ready() -> void:
	Global.cargador_pelotitas_actualizado.connect(_on_cargador_pelotitas_actualizado)
	# Persistencia de vidas entre recargas de nivel
	if not vidas_inicializadas:
		vidas_guardadas = vidas_maximas
		vidas_inicializadas = true
		niveles_jugados = 0
		niveles_ganados_run = 0
		if not dificultad_actual:
			dificultad_actual = dificultad_default
		EstadisticasRun.empezar_run()
	vidas_actuales = vidas_guardadas

	if ReliquiasManager.obtenidas.is_empty():
		for reliquia in reliquias_iniciales:
			ReliquiasManager.obtener(reliquia)
		if monedas_iniciales > 0:
			Global.actualizar_monedas(monedas_iniciales)

	reiniciar_nivel()
	
	if gato and gato.disparador_pelotitas:
		gato.disparador_pelotitas.disparo.connect(disparar_bola)
	
	# Buscar cargador si no está asignado
	if not cargador_nivel:
		cargador_nivel = get_tree().root.find_child("CargadorDeNivel", true, false) as CargadorDeNivel
	if not selector_niveles:
		selector_niveles = get_tree().root.find_child("SelectorDeNiveles", true, false) as SelectorDeNiveles
	
	if cargador_nivel:
		cargador_nivel.nivel_construido.connect(recalcular_meta)
	if selector_niveles:
		selector_niveles.nivel_elegido.connect(al_elegir_salida)
	
	# Inicializar conteo
	call_deferred("escanear_ovillos_existentes")

func reiniciar_nivel() -> void:
	if dificultad_actual:
		porcentaje_ovillos_requerido = dificultad_actual.porcentaje_para(niveles_jugados * ReliquiasManager.multiplicador_dificultad())
	finalizando = false
	es_meta_cumplida = false
	puntos_totales = 0
	puntos_obtenidos = 0
	ovillos_registrados.clear()
	bolas_restantes = bolas_maximas
	vidas_actuales = vidas_guardadas
	ReliquiasManager.al_empezar_nivel(self)
	estado_actual = EstadoDeJuego.LANZANDO_BOLAS
	nivel_reiniciado.emit()
	call_deferred("escanear_ovillos_existentes")

func conectar_sala(cargador : CargadorDeNivel, selector : SelectorDeNiveles) -> void:
	cargador_nivel = cargador
	selector_niveles = selector
	if cargador and not cargador.nivel_construido.is_connected(recalcular_meta):
		cargador.nivel_construido.connect(recalcular_meta)
	if selector and not selector.nivel_elegido.is_connected(al_elegir_salida):
		selector.nivel_elegido.connect(al_elegir_salida)

func escanear_ovillos_existentes() -> void:
	var nodos = get_tree().get_nodes_in_group("ovillos")
	for nodo in nodos:
		if nodo is Ovillo:
			registrar_ovillo(nodo)
	recalcular_meta()
	vidas_cambiadas.emit(vidas_actuales, vidas_maximas)
	bola_usada.emit(bolas_restantes)

func registrar_ovillo(ovillo : Ovillo) -> void:
	if not ovillos_registrados.has(ovillo):
		ovillos_registrados.append(ovillo)
		puntos_totales += puntaje_de(ovillo)
		if not ovillo.ovillo_desactivado.is_connected(al_desactivar_ovillo):
			ovillo.ovillo_desactivado.connect(al_desactivar_ovillo)
		
		if not ovillo.rebobinar_bola.is_connected(al_rebobinar_rebote):
			ovillo.rebobinar_bola.connect(al_rebobinar_rebote)
		recalcular_meta()

func registrar_ovillo_destruido(ovillo : Ovillo) -> void:
	puntos_obtenidos += puntaje_de(ovillo)
	EstadisticasRun.registrar_ovillo_roto(ovillo.tipo_ovillo)
	emitir_actualizacion_ovillos()
	
	if not es_meta_cumplida and puntos_obtenidos >= puntos_requeridos:
		es_meta_cumplida = true
		meta_alcanzada.emit(true)

func al_desactivar_ovillo(ovillo : Ovillo) -> void:
	# Respaldo por si se emite la señal
	pass

func puntaje_de(ovillo : Ovillo) -> int:
	return ovillo.obtener_puntaje() if ovillo.tipo_ovillo else 1

func recalcular_meta() -> void:
	if puntos_totales > 0:
		puntos_requeridos = maxi(1, int(ceil(float(puntos_totales) * porcentaje_ovillos_requerido)))
	else:
		puntos_requeridos = 1
	
	emitir_actualizacion_ovillos()

func emitir_actualizacion_ovillos() -> void:
	var porcentaje_actual = 0.0
	if puntos_totales > 0:
		porcentaje_actual = float(puntos_obtenidos) / float(puntos_totales)
	puntos_actualizados.emit(puntos_obtenidos, puntos_requeridos, puntos_totales, porcentaje_actual)

# ======= SISTEMA DE VIDAS ===


func perder_vida(cantidad : int = 1) -> void:
	vidas_actuales = clampi(vidas_actuales - cantidad, 0, vidas_maximas)
	vidas_guardadas = vidas_actuales
	vidas_cambiadas.emit(vidas_actuales, vidas_maximas)
	
	if vidas_actuales <= 0:
		estado_actual = EstadoDeJuego.GAME_OVER
		game_over.emit()
		print("GAME OVER - Sin vidas restantes")

func ganar_vida(cantidad : int = 1) -> void:
	vidas_actuales = clampi(vidas_actuales + cantidad, 0, vidas_maximas)
	vidas_guardadas = vidas_actuales
	vidas_cambiadas.emit(vidas_actuales, vidas_maximas)

func reiniciar_vidas() -> void:
	vidas_guardadas = vidas_maximas
	vidas_actuales = vidas_maximas
	vidas_cambiadas.emit(vidas_actuales, vidas_maximas)

# ======= DISPARO Y FIN DE NIVEL ===


func disparar_bola() -> void:
	if estado_actual != EstadoDeJuego.LANZANDO_BOLAS:
		return

	if Global.cargador_de_pelotitas.is_empty():
		return

	if not get_tree().get_nodes_in_group("bolas_de_pelos").is_empty():
		return
	
	
	#if bolas_restantes > 0:
		#bolas_restantes -= 1
		##bolas_restantes = Global.cargador_de_pelotitas.size() #aver si soluciona el bug
		#bola_usada.emit(bolas_restantes)
	estado_actual = EstadoDeJuego.ESPERANDO_BOLA
	gato_lanza_bola.emit()


func registrar_salida_de_bola() -> void:
	if estado_actual != EstadoDeJuego.LANZANDO_BOLAS:
		return
	if not Global.cargador_de_pelotitas.is_empty():
		return
	if get_tree().get_nodes_in_group("bolas_de_pelos").is_empty():
		cambiar_gato()

func cambiar_gato() -> void:
	estado_actual = EstadoDeJuego.LANZANDO_GATO
	lanzar_gato.emit()

func al_elegir_salida(tipo_sala : TipoDeSala.Tipo) -> void:
	finalizar_nivel(tipo_sala)

func finalizar_nivel(tipo_sala : int = -1) -> void:
	# El nivel SOLO se evalúa si ya se lanzaron todas las bolas Y se disparó al gato
	if estado_actual != EstadoDeJuego.LANZANDO_GATO:
		return
	if finalizando or estado_actual == EstadoDeJuego.NIVEL_COMPLETADO or estado_actual == EstadoDeJuego.GAME_OVER:
		return
	finalizando = true
	
	print("Evaluando nivel. Puntos: %d / Requeridos: %d" % [puntos_obtenidos, puntos_requeridos])
	
	niveles_jugados += 1
	if puntos_obtenidos >= puntos_requeridos:
		# ¡ÉXITO!
		estado_actual = EstadoDeJuego.NIVEL_COMPLETADO
		es_meta_cumplida = true
		niveles_ganados_run += 1
		EstadisticasRun.registrar_nivel(puntos_obtenidos, true)
		if dificultad_actual and niveles_ganados_run >= dificultad_actual.niveles_para_ganar:
			print("¡RUN GANADA!")
			nivel_completado.emit(true)
			get_tree().create_timer(2.0).timeout.connect(volver_al_menu.bind(true))
			return
		nivel_completado.emit(true)
		print("¡NIVEL SUPERADO CON ÉXITO!")

		if tipo_sala >= 0:
			get_tree().create_timer(1.2).timeout.connect(func():
				sala_pedida.emit(tipo_sala)
			)
	else:
		# FALLÓ LA META -> Pierde vida y avanza igual a la siguiente sala
		perder_vida(1)
		EstadisticasRun.registrar_nivel(puntos_obtenidos, false)
		nivel_completado.emit(false)
		
		if vidas_actuales > 0:
			estado_actual = EstadoDeJuego.NIVEL_COMPLETADO
			if tipo_sala >= 0:
				print("Nivel fallado. Vidas restantes: %d. Avanzando a la siguiente sala..." % vidas_actuales)
				get_tree().create_timer(1.2).timeout.connect(func():
					sala_pedida.emit(tipo_sala)
				)
			else:
				print("Nivel fallado sin salida elegida. Vidas restantes: %d. Reiniciando nivel..." % vidas_actuales)
				get_tree().create_timer(1.5).timeout.connect(func():
					reiniciar_nivel_actual()
				)
		else:
			print("GAME OVER - Volviendo al menu principal...")
			vidas_guardadas = vidas_maximas
			get_tree().create_timer(2.0).timeout.connect(volver_al_menu)

func fallar_por_atasco() -> void:
	if estado_actual != EstadoDeJuego.LANZANDO_GATO or finalizando:
		return
	finalizando = true
	print("Gato atascado. Pierde una vida y se repite el nivel.")
	perder_vida(1)
	nivel_completado.emit(false)
	if vidas_actuales > 0:
		get_tree().create_timer(1.5).timeout.connect(reiniciar_nivel_actual)
	else:
		vidas_guardadas = vidas_maximas
		get_tree().create_timer(2.0).timeout.connect(volver_al_menu)


func al_rebobinar_rebote ()-> void:
	bolas_restantes += 1


func reiniciar_nivel_actual() -> void:
	if sala_pedida.get_connections().is_empty():
		get_tree().reload_current_scene()
	else:
		sala_pedida.emit(TipoDeSala.Tipo.NORMAL)



#func _on_eligio_una_comida():#funcion q se llama desde global, dsp de elegir una comida en el selector de comidas
	#bolas_de_pelo_disponibles = Global.get_comidas_elegidas()
#
#func restablecer_tablero_pelotitas(): #la dejo por si metemos el efecto "al ser golpeado restablece el tablero de ovillos"
	#pass


func sortear_rareza() -> Rareza.Nivel:
	var azar : float = randf() * (probabilidad_comun + probabilidad_raro + probabilidad_epico + probabilidad_legendario)
	var acumulado : float = 0.0
	var probabilidades : Array[float] = [probabilidad_comun, probabilidad_raro, probabilidad_epico, probabilidad_legendario]
	for nivel in probabilidades.size():
		acumulado += probabilidades[nivel]
		if azar <= acumulado:
			return nivel
	return Rareza.Nivel.COMUN


static func filtrar_por_rareza(candidatos : Array, rareza : Rareza.Nivel) -> Array:
	var filtrados : Array = []
	var nivel : int = rareza
	while nivel >= Rareza.Nivel.COMUN and filtrados.is_empty():
		filtrados = candidatos.filter(func(item : Resource) -> bool: return item.rareza == nivel)
		nivel -= 1
	if filtrados.is_empty():
		return candidatos
	return filtrados


func volver_al_menu(gano : bool = false) -> void:
	EstadisticasRun.terminar_run(gano)
	dificultad_actual = null
	vidas_inicializadas = false
	ReliquiasManager.obtenidas.clear()
	ReliquiasManager.explosion_instantanea = false
	ReliquiasManager.catnip_stackeable = false
	ReliquiasManager.opciones_loot = 1
	ReliquiasManager.salidas_reveladas = false
	ReliquiasManager.bolas_atraviesan = false
	Transicion.cambiar_escena(escena_stats if not escena_stats.is_empty() else escena_menu)


func _on_cargador_pelotitas_actualizado():
	#print("en teoria acabo de tira una bola, recibido en game manager")
	#el diablo q es ete codigo jdasjasdj
	if estado_actual == EstadoDeJuego.ESPERANDO_BOLA:
		estado_actual = EstadoDeJuego.LANZANDO_BOLAS
