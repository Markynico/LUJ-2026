extends Node

signal reliquia_obtenida(reliquia : Reliquia)

var obtenidas : Array[Reliquia] = []
var game_manager_actual : GameManager
var explosion_instantanea : bool = false
var ultima_ofrecida : Reliquia


func obtener(reliquia : Reliquia) -> void:
	if not reliquia:
		return
	obtenidas.append(reliquia)
	if not is_instance_valid(game_manager_actual):
		game_manager_actual = null
	reliquia.al_obtener(game_manager_actual)
	reliquia_obtenida.emit(reliquia)


func al_empezar_nivel(game_manager : GameManager) -> void:
	game_manager_actual = game_manager
	for reliquia in obtenidas:
		reliquia.al_empezar_nivel(game_manager)


func al_preparar_disparo(datos : DatosDisparo) -> void:
	for reliquia in obtenidas:
		reliquia.al_preparar_disparo(datos)
