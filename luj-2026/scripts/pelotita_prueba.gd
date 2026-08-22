extends RigidBody2D

@export var fuerza_rebote : float = 350
@export var audio : AudioStreamPlayer


func _on_body_shape_entered(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	if body is RigidBody2D:
		return
	var normal = global_position.direction_to(body.global_position)
	apply_central_impulse(-normal * fuerza_rebote)
	audio.play()
	body.queue_free()
