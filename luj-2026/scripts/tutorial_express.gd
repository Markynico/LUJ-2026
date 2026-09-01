extends Node2D

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@export var num_maximo_animaciones : int = 5
var contador_tutorial : int = 0

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("espacio"):
		contador_tutorial += 1
		var nombre_animacion : String = "tutorial_" + str(contador_tutorial)
		animation_player.play(nombre_animacion)
