@icon("res://iconos_custom/explosion.svg")
class_name Explosion
extends Node2D

@export var area_2d: Area2D
@export var animated_sprite_explosion : AnimatedSprite2D

func activar_explosion(): #se llama desde OVILLO
	#sprite_2d.show()
	#$AnimationPlayer.play("probando")
	animated_sprite_explosion.play()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Ovillo:
		body.recibir_impacto()


func _on_sprites_explosion_frame_changed() -> void:
	if animated_sprite_explosion.frame == 22: #pq justo en la 22 hace la explosion grande
		#dsp la volvemos a timear con la animacion de verdad
		#print("DEBERIA REACTIVARRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR")
		reactivar_colisiones()


func reactivar_colisiones(): #en realidad esta es la funcion q nos ayuda a q otros ovillos exploten
	area_2d.set_deferred("monitoring", true)
