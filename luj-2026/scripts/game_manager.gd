@icon("res://iconos_custom/gobot.svg")
class_name GameManager
extends Node

signal bola_usada(bolas_restantes : int)
signal gato_lanza_bola
signal lanzar_gato
signal vidas_cambiadas(vidas_actuales : int, vidas_maximas : int)
signal ovillos_actualizados(destruidos : int, requeridos : int, total : int, porcentaje_actual : float)
signal meta_alcanzada(es_meta : bool)
signal nivel_completado(exito : bool)
signal game_over

enum EstadoDeJuego {
	ESPERANDO, # Al iniciar el nivel y elegir los poderes
	TIENDA, # Mientras se compra
	LANZANDO_BOLAS,
	LANZANDO_GATO,
	NIVEL_COMPLETADO,
	GAME_OVER
}

static var instancia_actual: GameManager
static var vidas_guardadas: int = 3
static var vidas_inicializadas: bool = false

@export var gato : Gato
@export var cargador_nivel : CargadorDeNivel
@export var selector_niveles : SelectorDeNiveles
@export var bolas_maximas : int = 20
@export var vidas_maximas : int = 3
@export_range(0.1, 1.0, 0.05) var porcentaje_ovillos_requerido : float = 0.70

var bolas_restantes : int = 0:
	set(valor):
		bolas_restantes = valor
		bola_usada.emit(bolas_restantes)
var vidas_actuales : int = 3
var estado_actual : EstadoDeJuego = EstadoDeJuego.ESPERANDO

var total_ovillos : int = 0
var ovillos_destruidos : int = 0
var ovillos_requeridos : int = 0
var es_meta_cumplida : bool = false
var _ovillos_registrados : Array[Ovillo] = []
var _finalizando : bool = false

func _enter_tree() -> void:
	instancia_actual = self

func _ready() -> void:
	_finalizando = false
	bolas_restantes = bolas_maximas
	
	# Persistencia de vidas entre recargas de nivel
	if not vidas_inicializadas:
		vidas_guardadas = vidas_maximas
		vidas_inicializadas = true
	vidas_actuales = vidas_guardadas
	
	ReliquiasManager.al_empezar_nivel(self)
	estado_actual = EstadoDeJuego.LANZANDO_BOLAS
	
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
		selector_niveles.nivel_elegido.connect(_on_salida_elegida)
	
	# Inicializar conteo
	call_deferred("escanear_ovillos_existentes")

func escanear_ovillos_existentes() -> void:
	var nodos = get_tree().get_nodes_in_group("ovillos")
	for nodo in nodos:
		if nodo is Ovillo:
			registrar_ovillo(nodo)
	recalcular_meta()
	vidas_cambiadas.emit(vidas_actuales, vidas_maximas)
	bola_usada.emit(bolas_restantes)

func registrar_ovillo(ovillo : Ovillo) -> void:
	if not _ovillos_registrados.has(ovillo):
		_ovillos_registrados.append(ovillo)
		total_ovillos = _ovillos_registrados.size()
		if not ovillo.ovillo_desactivado.is_connected(_on_ovillo_desactivado):
			ovillo.ovillo_desactivado.connect(_on_ovillo_desactivado)
		recalcular_meta()

func registrar_ovillo_destruido(_ovillo : Ovillo) -> void:
	ovillos_destruidos += 1
	_emitir_actualizacion_ovillos()
	
	if not es_meta_cumplida and ovillos_destruidos >= ovillos_requeridos:
		es_meta_cumplida = true
		meta_alcanzada.emit(true)

func _on_ovillo_desactivado(ovillo : Ovillo) -> void:
	# Respaldo por si se emite la señal
	pass

func recalcular_meta() -> void:
	if cargador_nivel and cargador_nivel.nivel and "porcentaje_ovillos_requerido" in cargador_nivel.nivel:
		porcentaje_ovillos_requerido = cargador_nivel.nivel.porcentaje_ovillos_requerido
	
	if total_ovillos > 0:
		ovillos_requeridos = maxi(1, int(ceil(float(total_ovillos) * porcentaje_ovillos_requerido)))
	else:
		ovillos_requeridos = 1
	
	_emitir_actualizacion_ovillos()

func _emitir_actualizacion_ovillos() -> void:
	var porcentaje_actual = 0.0
	if total_ovillos > 0:
		porcentaje_actual = float(ovillos_destruidos) / float(total_ovillos)
	ovillos_actualizados.emit(ovillos_destruidos, ovillos_requeridos, total_ovillos, porcentaje_actual)

# ======= SISTEMA DE VIDAS ==========

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

# ======= DISPARO Y FIN DE NIVEL ==========

func disparar_bola() -> void:
	if estado_actual != EstadoDeJuego.LANZANDO_BOLAS:
		return
	
	if bolas_restantes > 0:
		bolas_restantes -= 1
		bola_usada.emit(bolas_restantes)
		gato_lanza_bola.emit()
	
	if bolas_restantes <= 0:
		cambiar_gato()

func cambiar_gato() -> void:
	estado_actual = EstadoDeJuego.LANZANDO_GATO
	lanzar_gato.emit()

func _on_salida_elegida(tipo_sala : TipoDeSala.Tipo) -> void:
	finalizar_nivel(tipo_sala)

func finalizar_nivel(tipo_sala : int = -1) -> void:
	# El nivel SOLO se evalúa si ya se lanzaron todas las bolas Y se disparó al gato
	if estado_actual != EstadoDeJuego.LANZANDO_GATO:
		return
	if _finalizando or estado_actual == EstadoDeJuego.NIVEL_COMPLETADO or estado_actual == EstadoDeJuego.GAME_OVER:
		return
	_finalizando = true
	
	print("Evaluando nivel. Destruidos: %d / Requeridos: %d" % [ovillos_destruidos, ovillos_requeridos])
	
	if ovillos_destruidos >= ovillos_requeridos:
		# ¡ÉXITO!
		estado_actual = EstadoDeJuego.NIVEL_COMPLETADO
		es_meta_cumplida = true
		nivel_completado.emit(true)
		print("¡NIVEL SUPERADO CON ÉXITO!")
		
		if tipo_sala == TipoDeSala.Tipo.TIENDA:
			get_tree().create_timer(1.2).timeout.connect(func():
				if ResourceLoader.exists("res://escenas/tienda.tscn"):
					get_tree().change_scene_to_file("res://escenas/tienda.tscn")
			)
	else:
		# FALLÓ LA META -> Pierde vida y reinicia nivel
		perder_vida(1)
		nivel_completado.emit(false)
		
		if vidas_actuales > 0:
			print("Nivel fallado. Vidas restantes: %d. Reiniciando nivel en 1.5s..." % vidas_actuales)
			get_tree().create_timer(1.5).timeout.connect(func():
				reiniciar_nivel_actual()
			)
		else:
			print("GAME OVER - Fin del juego. Reiniciando vidas...")
			vidas_guardadas = vidas_maximas
			get_tree().create_timer(2.0).timeout.connect(func():
				reiniciar_nivel_actual()
			)

func reiniciar_nivel_actual() -> void:
	get_tree().reload_current_scene()
