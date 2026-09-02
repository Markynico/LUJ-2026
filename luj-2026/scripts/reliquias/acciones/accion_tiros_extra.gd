class_name AccionTirosExtra
extends AccionReliquia

##tiros que se suman al nivel actual
@export var tiros : int = 1


func ejecutar(contexto : Dictionary) -> bool:
	var game_manager : GameManager = game_manager_de(contexto)
	if not game_manager:
		return false
	game_manager.bolas_restantes += tiros
	return true
