class_name ReliquiaTarjetaCredito
extends Reliquia

##descuento en la tienda, 0.25 = 25%
@export var descuento : float = 0.25
##que tan rapido escala la dificultad, 1.5 = 50% mas rapido
@export var escala_dificultad : float = 1.5


func descuento_tienda() -> float:
	return descuento


func multiplicador_dificultad() -> float:
	return escala_dificultad
