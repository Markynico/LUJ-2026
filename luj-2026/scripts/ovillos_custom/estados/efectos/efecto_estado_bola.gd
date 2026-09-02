class_name EfectoEstadoBola
extends EfectoEstadoOvillo

##multiplicador de la velocidad de la bola despues de rebotar contra el ovillo
@export var multiplicador_velocidad : float = 1.0
##si el rebote quita el estado
@export var quitar_estado_al_rebotar : bool = false


func al_rebotar_bola(ovillo : Ovillo, bola : BolaDePelos) -> void:
	bola.linear_velocity *= multiplicador_velocidad
	if quitar_estado_al_rebotar and estado:
		ovillo.quitar_estado(estado)
