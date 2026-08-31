class_name EfectoExplosion
extends EfectosOvillo

var explosion_scene: PackedScene = preload("res://escenas/componentes/explosion.tscn")

func al_recibir_impacto(ovillo: Ovillo):
	var explosion = explosion_scene.instantiate()
	ReliquiasManager.al_explotar(explosion)
	ovillo.get_parent().call_deferred("add_child", explosion)
	explosion.set_deferred("global_position", ovillo.global_position)
	ovillo.explotar(explosion) #aca le digo al ovillo q explote
	#alla se hace el efectito de titititin y despues llamo a explosion.activar_explosion() :D
