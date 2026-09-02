class_name EfectoGato
extends EfectoReliquia

##ovillos que puede romper el gato al ser lanzado, 0 = no cambia
@export var impactos_maximos : int = 0
##si el gato puede moverse horizontalmente
@export var movimiento_horizontal : bool = false


func al_obtener(game_manager : GameManager) -> void:
	aplicar(game_manager)


func al_empezar_nivel(game_manager : GameManager) -> void:
	aplicar(game_manager)


func aplicar(game_manager : GameManager) -> void:
	if not game_manager or not game_manager.gato:
		return
	if impactos_maximos > 0:
		game_manager.gato.impactos_maximos = impactos_maximos
	if movimiento_horizontal:
		game_manager.gato.habilitar_movimiento_horizontal()
