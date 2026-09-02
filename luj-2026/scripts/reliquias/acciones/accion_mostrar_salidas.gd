class_name AccionMostrarSalidas
extends AccionReliquia


func ejecutar(contexto : Dictionary) -> bool:
	var game_manager : GameManager = game_manager_de(contexto)
	ReliquiasManager.salidas_reveladas = true
	if game_manager and game_manager.selector_niveles:
		game_manager.selector_niveles.mostrar_salidas()
	return true
