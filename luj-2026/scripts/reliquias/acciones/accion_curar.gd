class_name AccionCurar
extends AccionReliquia

##vidas que se recuperan, negativo para perder vidas
@export var vidas : int = 1
##si esta prendido, curar con las vidas llenas no hace nada ni cuenta como uso
@export var solo_si_falta_vida : bool = false


func ejecutar(contexto : Dictionary) -> bool:
	var game_manager : GameManager = game_manager_de(contexto)
	if not game_manager:
		return false
	if vidas >= 0:
		if solo_si_falta_vida and game_manager.vidas_actuales >= game_manager.vidas_maximas:
			return false
		game_manager.ganar_vida(vidas)
	else:
		game_manager.perder_vida(-vidas)
	return true
