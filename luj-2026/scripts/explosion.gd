class_name Explosion
extends Node2D

@onready var area_2d: Area2D = %Area2D

func _ready() -> void:
	area_2d.set_deferred("monitoring", true)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Ovillo:
		print("hay ovillo en explosion")
		body.recibir_impacto()
		#+ animacion q se esta ejecutando sola en el animation player
