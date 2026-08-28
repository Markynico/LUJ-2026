class_name ReliquiaWhiskas
extends Reliquia

##slots de vida que saca
@export var slots_menos : int = 1
##multiplicador de velocidad de los tiros
@export var multiplicador_velocidad : float = 1.25

var manager_aplicado : GameManager


func al_obtener(game_manager : GameManager) -> void:
	aplicar(game_manager)


func al_empezar_nivel(game_manager : GameManager) -> void:
	aplicar(game_manager)


func al_preparar_disparo(datos : DatosDisparo) -> void:
	datos.velocidad_inicial *= multiplicador_velocidad


func aplicar(game_manager : GameManager) -> void:
	if not game_manager or game_manager == manager_aplicado:
		return
	manager_aplicado = game_manager
	game_manager.vidas_maximas = maxi(1, game_manager.vidas_maximas - slots_menos)
	game_manager.vidas_actuales = mini(game_manager.vidas_actuales, game_manager.vidas_maximas)
	GameManager.vidas_guardadas = game_manager.vidas_actuales
	game_manager.vidas_cambiadas.emit(game_manager.vidas_actuales, game_manager.vidas_maximas)
