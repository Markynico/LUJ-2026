class_name EfectoEstadoContagiar
extends EfectoEstadoOvillo

##estado que se aplica a los ovillos cercanos
@export var estado_a_aplicar : EstadoOvillo
##distancia maxima a la que contagia
@export var radio : float = 80.0
##si contagia cuando el ovillo se rompe
@export var al_romper : bool = true
##si contagia cuando el estado se quita
@export var al_perder_estado : bool = false


func contagiar(ovillo : Ovillo) -> void:
	if not estado_a_aplicar:
		return
	for otro in ovillo.get_tree().get_nodes_in_group("ovillos"):
		if otro != ovillo and otro.activado and otro.global_position.distance_to(ovillo.global_position) <= radio:
			otro.aplicar_estado(estado_a_aplicar)


func al_romperse(ovillo : Ovillo) -> void:
	if al_romper:
		contagiar(ovillo)


func al_quitar(ovillo : Ovillo) -> void:
	if al_perder_estado:
		contagiar(ovillo)
