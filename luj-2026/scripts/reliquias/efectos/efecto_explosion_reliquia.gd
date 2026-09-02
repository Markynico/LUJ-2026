class_name EfectoExplosionReliquia
extends EfectoReliquia

##multiplicador del tamaño y la fuerza de las explosiones
@export var multiplicador : float = 2.0
##probabilidad en porcentaje de aplicar el multiplicador a cada explosion
@export_range(0.0, 100.0) var probabilidad : float = 100.0
##probabilidad en porcentaje de perder una vida cada vez que explota una bomba
@export_range(0.0, 100.0) var probabilidad_perder_vida : float = 0.0


func al_explotar(explosion : Explosion) -> void:
	var game_manager : GameManager = ReliquiasManager.game_manager_actual
	if randf() * 100.0 <= probabilidad:
		explosion.scale *= multiplicador
		explosion.fuerza_impulso *= multiplicador
	if probabilidad_perder_vida > 0.0 and randf() * 100.0 <= probabilidad_perder_vida and is_instance_valid(game_manager):
		game_manager.perder_vida(1)
