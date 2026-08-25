class_name ReliquiaTiroExtra
extends Reliquia

##tiros de mas que se suman al empezar cada nivel
@export var tiros_extra : int = 1


func al_obtener(game_manager : GameManager) -> void:
	if game_manager:
		game_manager.bolas_restantes += tiros_extra


func al_empezar_nivel(game_manager : GameManager) -> void:
	game_manager.bolas_restantes += tiros_extra
