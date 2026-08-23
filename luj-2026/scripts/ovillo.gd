class_name Ovillo
extends StaticBody2D

@export var audio : AudioStreamPlayer
@export var forma_colision : CollisionShape2D
@export var sprite : Sprite2D


func recibir_impacto() -> void:
	forma_colision.set_deferred("disabled", true)
	sprite.hide()
	if audio and audio.stream:
		audio.play()
		await audio.finished
	queue_free()
