class_name Juego
extends Node2D

@export var game_manager : GameManager
@export var gato : Gato
##cargador unico donde se construyen los niveles
@export var cargador : CargadorDeNivel
##selector de salidas hacia la proxima sala
@export var selector : SelectorDeNiveles
##capa donde vive el HUD, se oculta fuera de los niveles
@export var capa_interfaz : CanvasLayer
@export var camara : Camera2D
##zoom de la camara mientras el gato escupe la bola
@export var zoom_disparo : Vector2 = Vector2(1.5, 1.5)
##segundos que tarda el zoom de disparo
@export var duracion_zoom : float = 0.4
##corrimiento de la camara respecto del gato durante el zoom
@export var offset_zoom : Vector2 = Vector2(0, 120)
##tipo de sala con la que arranca la partida
@export var sala_inicial : TipoDeSala.Tipo = TipoDeSala.Tipo.NORMAL
##ruta de la escena de sala para cada tipo, los niveles normales no usan escena
@export var escenas_por_sala : Dictionary[TipoDeSala.Tipo, String] = {
	TipoDeSala.Tipo.TIENDA: "uid://dfm5y8q2s1txc",
	TipoDeSala.Tipo.LOOT: "uid://8l4mghblkql7",
}

var sala_actual : Node
var capa_salas : CanvasLayer
var posicion_camara_inicial : Vector2
var zoom_camara_inicial : Vector2
var tween_camara : Tween


func _ready() -> void:
	AudioManager.reproducir_musica(AudioManager.musica_juego)
	if camara:
		posicion_camara_inicial = camara.global_position
		zoom_camara_inicial = camara.zoom
		game_manager.gato_lanza_bola.connect(acercar_camara)
		gato.disparador_pelotitas.bola_escupida.connect(alejar_camara)
	capa_salas = CanvasLayer.new()
	capa_salas.layer = 2
	add_child(capa_salas)
	game_manager.sala_pedida.connect(cambiar_sala)
	cambiar_sala.call_deferred(sala_inicial)


func acercar_camara() -> void:
	AudioManager.reproducir_sfx(EfectoDeSonido.Tipo.WHOOSH_CAMARA_RAPIDO)
	mover_camara(gato.global_position + offset_zoom, zoom_disparo)


func alejar_camara() -> void:
	AudioManager.reproducir_sfx(EfectoDeSonido.Tipo.WHOOSH_CAMARA_RAPIDO)
	mover_camara(posicion_camara_inicial, zoom_camara_inicial)


func mover_camara(posicion : Vector2, zoom : Vector2) -> void:
	if tween_camara:
		tween_camara.kill()
	tween_camara = create_tween().set_parallel().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween_camara.tween_property(camara, "global_position", posicion, duracion_zoom)
	tween_camara.tween_property(camara, "zoom", zoom, duracion_zoom)


func cambiar_sala(tipo : TipoDeSala.Tipo) -> void:
	var es_nivel : bool = tipo == TipoDeSala.Tipo.NORMAL
	var ruta : String = escenas_por_sala.get(tipo, "")
	if not es_nivel and ruta.is_empty():
		return
	if sala_actual:
		sala_actual.queue_free()
		sala_actual = null
	if not es_nivel:
		sala_actual = load(ruta).instantiate()
		if sala_actual is Control:
			capa_salas.add_child(sala_actual, true)
		else:
			add_child(sala_actual, true)
		if sala_actual.has_signal("continuar_pedido"):
			sala_actual.continuar_pedido.connect(cambiar_sala.bind(TipoDeSala.Tipo.NORMAL))
	if cargador:
		cargador.visible = es_nivel
	if selector:
		selector.visible = es_nivel
	if capa_interfaz:
		capa_interfaz.visible = es_nivel
	gato.visible = es_nivel
	if es_nivel:
		empezar_nivel()
	elif cargador:
		cargador.limpiar_formas()


func empezar_nivel() -> void:
	cargador.construir_nivel_elegido()
	game_manager.conectar_sala(cargador, selector)
	gato.reiniciar()
	game_manager.reiniciar_nivel()
