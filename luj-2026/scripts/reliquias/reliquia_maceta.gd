class_name ReliquiaMaceta
extends Reliquia

##multiplicador de velocidad de los tiros
@export var multiplicador_velocidad : float = 1.3


func al_preparar_disparo(datos : DatosDisparo) -> void:
	datos.velocidad_inicial *= multiplicador_velocidad
