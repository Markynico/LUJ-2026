@tool
class_name SpawnOvillo
extends Node2D

##escena del ovillo que aparece en este punto al correr el juego
@export var escena_ovillo : PackedScene = preload("uid://dy3jqoayfdkwm")
##radio del circulito de vista previa en el editor
@export var radio_vista_previa : float = 8.0
@export var color_vista_previa : Color = Color(1.0, 0.8, 0.2, 0.8)


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	instanciar_ovillo()


func _draw() -> void:
	if Engine.is_editor_hint():
		draw_circle(Vector2.ZERO, radio_vista_previa, color_vista_previa)


func instanciar_ovillo() -> void:
	if not escena_ovillo:
		return
	var ovillo := escena_ovillo.instantiate()
	add_child(ovillo)
