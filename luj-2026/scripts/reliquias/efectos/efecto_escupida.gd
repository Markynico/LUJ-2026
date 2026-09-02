class_name EfectoEscupida
extends EfectoReliquia

##multiplicador de la velocidad de la animacion de escupir
@export var multiplicador_velocidad : float = 2.0
##si la bola sale al instante, sin esperar la animacion
@export var instantanea : bool = false


func multiplicador_velocidad_escupida() -> float:
	return multiplicador_velocidad


func escupida_instantanea() -> bool:
	return instantanea
