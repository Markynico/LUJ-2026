class_name ReliquiaRascador
extends Reliquia

func al_obtener(game_manager : GameManager) -> void:
	_activar_en_gato(game_manager)

func al_empezar_nivel(game_manager : GameManager) -> void:
	_activar_en_gato(game_manager)

func _activar_en_gato(game_manager : GameManager) -> void:
	if not game_manager or not game_manager.gato:
		return
	var gato = game_manager.gato
	if gato.has_method("habilitar_disparo_lateral"):
		gato.habilitar_disparo_lateral()
