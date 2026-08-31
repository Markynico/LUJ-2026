class_name ReliquiaTrayectoria
extends Reliquia

##rebotes que muestra la prediccion de trayectoria
@export var rebotes_predichos : int = 5
##pasos de simulacion de la trayectoria, mas pasos = linea mas larga
@export var pasos : int = 240


func al_preparar_disparo(datos : DatosDisparo) -> void:
	datos.rebotes = maxi(datos.rebotes, rebotes_predichos)
	datos.pasos = maxi(datos.pasos, pasos)
