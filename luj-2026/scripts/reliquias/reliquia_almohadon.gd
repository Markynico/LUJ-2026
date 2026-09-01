class_name ReliquiaAlmohadon
extends Reliquia

##slots de vida que agrega
@export var slots_extra : int = 1
##si esta activo los slots nuevos vienen con la vida llena
@export var slots_llenos : bool = false

var manager_aplicado : GameManager
var vidas_otorgadas : bool = false


func al_obtener(game_manager : GameManager) -> void:
	vidas_otorgadas = false
	aplicar(game_manager)
	otorgar_vidas(game_manager)


func al_empezar_nivel(game_manager : GameManager) -> void:
	aplicar(game_manager)
	otorgar_vidas(game_manager)


func otorgar_vidas(game_manager : GameManager) -> void:
	if not slots_llenos or vidas_otorgadas or not game_manager:
		return
	vidas_otorgadas = true
	game_manager.ganar_vida(slots_extra)


func aplicar(game_manager : GameManager) -> void:
	if not game_manager or game_manager == manager_aplicado:
		return
	manager_aplicado = game_manager
	game_manager.vidas_maximas += slots_extra
	game_manager.vidas_cambiadas.emit(game_manager.vidas_actuales, game_manager.vidas_maximas)
