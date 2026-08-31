class_name ReliquiaObjetoValioso
extends Reliquia

##multiplicador de puntos para todos los ovillos
@export var multiplicador : float = 2.0
##probabilidad en porcentaje de perder una vida por disparo
@export var probabilidad_perder_vida : float = 1.0


func multiplicador_puntos(tipo_ovillo : OvilloBase) -> float:
	return multiplicador


func al_disparar(game_manager : GameManager) -> void:
	if game_manager and randf() * 100.0 <= probabilidad_perder_vida:
		game_manager.perder_vida(1)
