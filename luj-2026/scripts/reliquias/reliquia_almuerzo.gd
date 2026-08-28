class_name ReliquiaAlmuerzo
extends Reliquia

##probabilidad de curar en vez de perder una vida
@export_range(0.0, 1.0) var chance_de_curar : float = 0.5


func al_obtener(game_manager : GameManager) -> void:
	if not game_manager:
		return
	if randf() < chance_de_curar:
		game_manager.ganar_vida(1)
	else:
		game_manager.perder_vida(1)
