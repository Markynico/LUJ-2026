@icon("res://iconos_custom/tap.svg")
extends Node

@export var escena_pelotita_prueba : PackedScene

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("click_izq"):
		var instancia : Node2D = escena_pelotita_prueba.instantiate()
		add_child(instancia)
		instancia.global_position = get_viewport().get_mouse_position()
