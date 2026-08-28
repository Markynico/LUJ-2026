class_name ReliquiaMessi
extends Reliquia

##multiplicador de gravedad de los tiros
@export var multiplicador_gravedad : float = 0.5
##multiplicador de velocidad de los tiros
@export var multiplicador_velocidad : float = 2.0


func al_preparar_disparo(datos : DatosDisparo) -> void:
	datos.gravedad *= multiplicador_gravedad
	datos.velocidad_inicial *= multiplicador_velocidad
