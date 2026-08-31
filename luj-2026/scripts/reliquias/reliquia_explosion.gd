class_name ReliquiaExplosion
extends Reliquia

##multiplicador de fuerza y radio de la explosion
@export var multiplicador : float = 2.0
##probabilidad en porcentaje de aplicar el multiplicador
@export var probabilidad : float = 100.0
##probabilidad en porcentaje de perder una vida cuando explota una bomba
@export var probabilidad_perder_vida : float = 0.0


func al_explotar(explosion : Explosion) -> void:
	if randf() * 100.0 <= probabilidad:
		explosion.scale *= multiplicador
		explosion.fuerza_impulso *= multiplicador
	if probabilidad_perder_vida > 0.0 and randf() * 100.0 <= probabilidad_perder_vida and ReliquiasManager.game_manager_actual:
		ReliquiasManager.game_manager_actual.perder_vida(1)
