class_name ReliquiaTapitaLapicera
extends Reliquia

## Cantidad de rebotes adicionales a predecir
@export var rebotes_extra : int = 2
## Si deja marcado en pantalla el rastro del último tiro
@export var dejar_camino_marcado : bool = true

func al_obtener(game_manager : GameManager) -> void:
	_activar_en_trayectoria(game_manager)

func al_empezar_nivel(game_manager : GameManager) -> void:
	_activar_en_trayectoria(game_manager)

func al_preparar_disparo(datos : DatosDisparo) -> void:
	datos.rebotes += rebotes_extra
	datos.pasos = maxi(datos.pasos, 220)

func _activar_en_trayectoria(game_manager : GameManager) -> void:
	if not game_manager or not game_manager.gato:
		return
	var disparador = game_manager.gato.disparador_pelotitas
	if disparador and disparador.has_node("TrayectoriaDisparo"):
		var trayectoria = disparador.get_node("TrayectoriaDisparo") as TrayectoriaDisparo
		if trayectoria:
			trayectoria.mostrar_camino_previo = true
