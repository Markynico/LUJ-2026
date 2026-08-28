class_name ReliquiaArmadura
extends Reliquia

##ovillos que puede romper el gato con la armadura puesta
@export var impactos_maximos : int = 9999


func al_obtener(game_manager : GameManager) -> void:
	aplicar(game_manager)


func al_empezar_nivel(game_manager : GameManager) -> void:
	aplicar(game_manager)


func aplicar(game_manager : GameManager) -> void:
	if game_manager and game_manager.gato:
		game_manager.gato.impactos_maximos = impactos_maximos
