class_name EfectoTrayectoria
extends EfectoReliquia

##rebotes que se suman a la prediccion de trayectoria
@export var rebotes_extra : int = 0
##rebotes minimos que predice la trayectoria, 0 = no cambia
@export var rebotes_minimos : int = 0
##pasos minimos de la simulacion, 0 = no cambia
@export var pasos_minimos : int = 0
##si deja el rastro de cada bola disparada
@export var mostrar_rastro : bool = false


func al_obtener(game_manager : GameManager) -> void:
	activar_rastro(game_manager)


func al_empezar_nivel(game_manager : GameManager) -> void:
	activar_rastro(game_manager)


func al_preparar_disparo(datos : DatosDisparo) -> void:
	datos.rebotes += rebotes_extra
	if rebotes_minimos > 0:
		datos.rebotes = maxi(datos.rebotes, rebotes_minimos)
	if pasos_minimos > 0:
		datos.pasos = maxi(datos.pasos, pasos_minimos)


func activar_rastro(game_manager : GameManager) -> void:
	var trayectoria : TrayectoriaDisparo
	if not mostrar_rastro or not game_manager or not game_manager.gato or not game_manager.gato.disparador_pelotitas:
		return
	trayectoria = game_manager.gato.disparador_pelotitas.get_node_or_null("TrayectoriaDisparo")
	if trayectoria:
		trayectoria.mostrar_camino_previo = true
