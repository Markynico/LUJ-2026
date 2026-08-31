class_name EstanteReliquias
extends Node2D

##borde izquierdo del primer estante
@export var origen : Vector2 = Vector2.ZERO
##espacio horizontal entre reliquias y distancia vertical entre estantes
@export var separacion : Vector2 = Vector2(12, 104)
##ancho utilizable de cada estante
@export var ancho_estante : float = 210.0
##alto en pixeles al que se escala el icono de cada reliquia
@export var alto_icono : float = 44.0

@export_group("Tarjeta de hover")
##escena de la tarjeta que se muestra al hacer hover
@export var escena_tarjeta : PackedScene = preload("uid://u6k76f6lyw8y")
##posicion en pantalla de la tarjeta de hover
@export var posicion_tarjeta : Vector2 = Vector2(1330, 240)
##escala de la tarjeta de hover
@export var escala_tarjeta : float = 0.6

var tarjeta : Tarjeta
var capa_tarjeta : CanvasLayer
var cursor : Vector2 = Vector2.ZERO


func _ready() -> void:
	capa_tarjeta = CanvasLayer.new()
	tarjeta = escena_tarjeta.instantiate()
	tarjeta.hover_activado = false
	tarjeta.position = posicion_tarjeta
	tarjeta.scale = Vector2.ONE * escala_tarjeta
	tarjeta.hide()
	capa_tarjeta.add_child(tarjeta)
	add_child(capa_tarjeta)
	for reliquia in ReliquiasManager.obtenidas:
		agregar_reliquia(reliquia)
	ReliquiasManager.reliquia_obtenida.connect(agregar_reliquia)


func agregar_reliquia(reliquia : Reliquia) -> void:
	var sprite : Sprite2D = Sprite2D.new()
	var area : Area2D = Area2D.new()
	var colision : CollisionShape2D = CollisionShape2D.new()
	var forma : RectangleShape2D = RectangleShape2D.new()
	var ancho : float
	if not reliquia or not reliquia.icono:
		return
	sprite.texture = reliquia.icono
	sprite.scale = Vector2.ONE * (alto_icono / reliquia.icono.get_height())
	ancho = reliquia.icono.get_width() * sprite.scale.x
	if cursor.x > 0.0 and cursor.x + ancho > ancho_estante:
		cursor = Vector2(0.0, cursor.y + separacion.y)
	sprite.position = origen + cursor + Vector2(ancho * 0.5, 0.0)
	cursor.x += ancho + separacion.x
	forma.size = reliquia.icono.get_size()
	colision.shape = forma
	area.add_child(colision)
	area.mouse_entered.connect(mostrar_tarjeta.bind(reliquia))
	area.mouse_exited.connect(tarjeta.desaparecer)
	sprite.add_child(area)
	add_child(sprite)


func mostrar_tarjeta(reliquia : Reliquia) -> void:
	tarjeta.recurso = reliquia
	tarjeta.aparecer()
