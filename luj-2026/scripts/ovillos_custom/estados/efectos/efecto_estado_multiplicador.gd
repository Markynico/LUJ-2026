class_name EfectoEstadoMultiplicador
extends EfectoEstadoOvillo

##multiplicador del puntaje del ovillo mientras tiene el estado
@export var multiplicador_puntos : float = 1.0
##multiplicador de las monedas del ovillo mientras tiene el estado
@export var multiplicador_monedas : float = 1.0


func modificar_puntaje(ovillo : Ovillo, puntos : int) -> int:
	return roundi(puntos * multiplicador_puntos)


func modificar_monedas(ovillo : Ovillo, monedas : int) -> int:
	return roundi(monedas * multiplicador_monedas)
