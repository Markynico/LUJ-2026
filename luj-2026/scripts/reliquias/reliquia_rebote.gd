class_name ReliquiaRebote
extends Reliquia

##multiplicador de la fuerza de rebote de las bolas de pelo
@export var multiplicador : float = 1.3


func multiplicador_rebote() -> float:
	return multiplicador


func al_preparar_disparo(datos : DatosDisparo) -> void:
	datos.fuerza_rebote *= multiplicador
