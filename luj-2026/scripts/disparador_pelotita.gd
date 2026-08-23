@icon("res://iconos_custom/tap.svg")
class_name DisparadorPelotita
extends Node2D

@export var escena_pelotita_prueba : PackedScene
##multiplicador de fuerza que se aplica para empujar la pelotita, se usa para multiplicar a la velocidad inicial (velocidad inicial se da por que tan lejos esta el mouse del michi)
@export var fuerza_disparo : float = 2.0
var velocidad_inicial : Vector2
var posicion_mouse : Vector2
#var gravedad = ProjectSettings.get_setting("physics/2d/default_gravity") arreglarrrr

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		#esta moviendo el mouse
		#posicion_mouse = get_viewport().get_mouse_position()
		posicion_mouse = get_global_mouse_position()
		velocidad_inicial = (global_position - posicion_mouse) * fuerza_disparo #no lo normalizo para q justamente dispare mas fuerte si el mouse esta lejos
	if Input.is_action_just_pressed("click_izq"):
		var instancia : BolaDePelos = escena_pelotita_prueba.instantiate()
		add_child(instancia)
		#instancia.global_position = posicion_mouse
		instancia.apply_impulse(-velocidad_inicial)
