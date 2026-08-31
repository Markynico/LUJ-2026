class_name ReliquiaBolaCristal
extends Reliquia


func al_obtener(game_manager : GameManager) -> void:
	ReliquiasManager.salidas_reveladas = true
	if game_manager and game_manager.selector_niveles:
		game_manager.selector_niveles.mostrar_salidas()
