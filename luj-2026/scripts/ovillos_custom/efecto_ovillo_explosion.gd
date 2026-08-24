class_name EfectoExplosion
extends EfectosOvillo

var explosion_scene: PackedScene = preload("res://escenas/componentes/explosion.tscn")

func al_recibir_impacto(ovillo: Ovillo):
	var explosion = explosion_scene.instantiate()
	ovillo.get_parent().add_child(explosion)
	explosion.global_position = ovillo.global_position
