class_name ReliquiaCuraPorRebotes
extends Reliquia

##rebotes necesarios para curar una vida
@export var rebotes_por_cura : int = 150
##curas totales antes de gastarse
@export var curas_maximas : int = 2

var rebotes : int = 0
var curas : int = 0


func al_obtener(game_manager : GameManager) -> void:
	rebotes = 0
	curas = 0


func al_rebotar(game_manager : GameManager) -> void:
	rebotes += 1
	if rebotes < rebotes_por_cura or not game_manager:
		return
	if game_manager.vidas_actuales >= game_manager.vidas_maximas:
		return
	rebotes -= rebotes_por_cura
	curas += 1
	game_manager.ganar_vida(1)
	if curas >= curas_maximas:
		ReliquiasManager.obtenidas.erase(self)
