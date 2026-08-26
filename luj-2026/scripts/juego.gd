class_name Juego
extends Node2D

@export var game_manager : GameManager
@export var gato : Gato
##capa donde vive el HUD, se oculta fuera de los niveles
@export var capa_interfaz : CanvasLayer
##tipo de sala con la que arranca la partida
@export var sala_inicial : TipoDeSala.Tipo = TipoDeSala.Tipo.NORMAL
##ruta de la escena de sala para cada tipo
@export var escenas_por_sala : Dictionary[TipoDeSala.Tipo, String] = {
	TipoDeSala.Tipo.NORMAL: "uid://8l4ogj2t5ql7",
	TipoDeSala.Tipo.TIENDA: "uid://dfm5y8q2s1txc",
	TipoDeSala.Tipo.LOOT: "uid://csalaloot000a1",
}

var sala_actual : Node
var capa_salas : CanvasLayer


func _ready() -> void:
	capa_salas = CanvasLayer.new()
	capa_salas.layer = 2
	add_child(capa_salas)
	game_manager.sala_pedida.connect(cambiar_sala)
	cambiar_sala.call_deferred(sala_inicial)


func cambiar_sala(tipo : TipoDeSala.Tipo) -> void:
	var ruta : String = escenas_por_sala.get(tipo, "")
	if ruta.is_empty():
		return
	if sala_actual:
		sala_actual.queue_free()
	sala_actual = load(ruta).instantiate()
	if sala_actual is Control:
		capa_salas.add_child(sala_actual, true)
	else:
		add_child(sala_actual, true)
	if sala_actual is Tienda:
		sala_actual.continuar_pedido.connect(cambiar_sala.bind(TipoDeSala.Tipo.NORMAL))
	var es_nivel : bool = tipo == TipoDeSala.Tipo.NORMAL
	if capa_interfaz:
		capa_interfaz.visible = es_nivel
	gato.visible = es_nivel
	if es_nivel:
		empezar_nivel()


func empezar_nivel() -> void:
	game_manager.conectar_sala(buscar_en_sala("CargadorDeNivel"), buscar_en_sala("SelectorDeNiveles"))
	gato.reiniciar()
	game_manager.reiniciar_nivel()


func buscar_en_sala(nombre : String) -> Node:
	return sala_actual.find_child(nombre, true, false)
