class_name ReliquiaCuraInmediata
extends Reliquia

##vidas que cura al obtenerla
@export var vidas : int = 1


func al_obtener(game_manager : GameManager) -> void:
	if game_manager:
		game_manager.ganar_vida(vidas)
