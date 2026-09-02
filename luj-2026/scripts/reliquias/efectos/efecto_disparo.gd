class_name EfectoDisparo
extends EfectoReliquia

##multiplicador de la gravedad de los tiros
@export var multiplicador_gravedad : float = 1.0
##multiplicador de la velocidad inicial de los tiros
@export var multiplicador_velocidad : float = 1.0
##rebotes extra que se predicen en la trayectoria
@export var rebotes_extra : int = 0
##tope de rebotes predichos, -1 = sin tope
@export var rebotes_predichos_maximos : int = -1
##si la bola mantiene siempre la rapidez con la que salio, sin perder velocidad en rebotes ni por gravedad
@export var velocidad_constante : bool = false


func al_preparar_disparo(datos : DatosDisparo) -> void:
	datos.gravedad *= multiplicador_gravedad
	datos.velocidad_inicial *= multiplicador_velocidad
	datos.rebotes += rebotes_extra
	if rebotes_predichos_maximos >= 0:
		datos.rebotes = mini(datos.rebotes, rebotes_predichos_maximos)
	if velocidad_constante:
		datos.velocidad_constante = true
