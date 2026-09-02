class_name RastroBola
extends Line2D

var bola : BolaDePelos


func seguir(bola_a_seguir : BolaDePelos) -> void:
	bola = bola_a_seguir
	add_point(bola.global_position)


func _physics_process(delta : float) -> void:
	if not is_instance_valid(bola):
		set_physics_process(false)
		return
	add_point(bola.global_position)
