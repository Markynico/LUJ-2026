class_name AccionReliquia
extends Resource


func game_manager_de(contexto : Dictionary) -> GameManager:
	var game_manager : GameManager = contexto.get("game_manager")
	if not game_manager:
		game_manager = ReliquiasManager.game_manager_actual
	if not is_instance_valid(game_manager):
		return null
	return game_manager


##devuelve true si la accion efectivamente hizo algo, para contar usos
func ejecutar(contexto : Dictionary) -> bool:
	return false
