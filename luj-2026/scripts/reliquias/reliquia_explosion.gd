class_name ReliquiaExplosion
extends Reliquia

##multiplicador de fuerza y radio de la explosion
@export var multiplicador : float = 2.0
##probabilidad en porcentaje de aplicar el multiplicador
@export var probabilidad : float = 100.0
##probabilidad en porcentaje de perder una vida cuando explota una bomba
@export var probabilidad_perder_vida : float = 0.0
##ovillo que se sustituye al spawnear, opcional
@export var ovillo_a_reemplazar : OvilloBase
##ovillo que aparece en lugar del reemplazado
@export var ovillo_reemplazo : OvilloBase


func reemplazar_ovillo(tipo_ovillo : OvilloBase) -> OvilloBase:
	if not ovillo_a_reemplazar or not ovillo_reemplazo:
		return tipo_ovillo
	if tipo_ovillo == ovillo_a_reemplazar or tipo_ovillo.contar_como == ovillo_a_reemplazar:
		return ovillo_reemplazo
	return tipo_ovillo


func al_explotar(explosion : Explosion) -> void:
	if randf() * 100.0 <= probabilidad:
		explosion.scale *= multiplicador
		explosion.fuerza_impulso *= multiplicador
	if probabilidad_perder_vida > 0.0 and randf() * 100.0 <= probabilidad_perder_vida and ReliquiasManager.game_manager_actual:
		ReliquiasManager.game_manager_actual.perder_vida(1)
