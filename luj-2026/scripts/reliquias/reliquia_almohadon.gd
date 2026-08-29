class_name ReliquiaAlmohadon
extends Reliquia

##slots de vida que agrega
@export var slots_extra : int = 1

var manager_aplicado : GameManager


func al_obtener(game_manager : GameManager) -> void:
	aplicar(game_manager)


func al_empezar_nivel(game_manager : GameManager) -> void:
	aplicar(game_manager)


func aplicar(game_manager : GameManager) -> void:
	if not game_manager or game_manager == manager_aplicado:
		return
	manager_aplicado = game_manager
	game_manager.vidas_maximas += slots_extra
	game_manager.vidas_cambiadas.emit(game_manager.vidas_actuales, game_manager.vidas_maximas)
