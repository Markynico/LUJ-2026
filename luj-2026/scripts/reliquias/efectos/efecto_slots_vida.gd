class_name EfectoSlotsVida
extends EfectoReliquia

##slots de vida que se suman a las vidas maximas, negativo para quitar
@export var slots : int = 1
##si los slots nuevos vienen llenos, solo la primera vez que se obtiene
@export var llenar_slots_nuevos : bool = false

var manager_aplicado : GameManager
var vidas_otorgadas : bool = false


func al_obtener(game_manager : GameManager) -> void:
	vidas_otorgadas = false
	aplicar(game_manager)


func al_empezar_nivel(game_manager : GameManager) -> void:
	aplicar(game_manager)


func aplicar(game_manager : GameManager) -> void:
	if not game_manager:
		return
	if game_manager != manager_aplicado:
		manager_aplicado = game_manager
		game_manager.vidas_maximas = maxi(1, game_manager.vidas_maximas + slots)
		if slots < 0:
			game_manager.vidas_actuales = mini(game_manager.vidas_actuales, game_manager.vidas_maximas)
			GameManager.vidas_guardadas = game_manager.vidas_actuales
		game_manager.vidas_cambiadas.emit(game_manager.vidas_actuales, game_manager.vidas_maximas)
	if llenar_slots_nuevos and slots > 0 and not vidas_otorgadas:
		vidas_otorgadas = true
		game_manager.ganar_vida(slots)
