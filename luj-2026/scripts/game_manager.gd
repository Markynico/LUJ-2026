@icon("res://iconos_custom/gobot.svg")
class_name GameManager
extends Node
 
signal bola_usada(bolas_restantes : int)
signal pedir_lanzar_bola
signal lanzar_gato

enum EstadoDeJuego{
	ESPERANDO, #Al iniciar el nivel y elegir los poderes
	TIENDA, #Mientras se compra
	JUGANDO,
	LANZANDO_GATO,
	NIVEL_COMPLETADO,
	GAME_OVER
}

@export var disparador : DisparadorPelotita
@export var bolas_maximas : int = 20

var bolas_restantes : int = 0
var estado_actual : EstadoDeJuego = EstadoDeJuego.ESPERANDO

func _ready() -> void:
	bolas_restantes = bolas_maximas
	estado_actual = EstadoDeJuego.JUGANDO
	
	disparador.disparo.connect(disparar_bola)




#======= FUNCIONES ==========

func disparar_bola() -> void:
	if estado_actual != EstadoDeJuego.JUGANDO:
		return
	
	if bolas_restantes <= 0:
		if estado_actual != EstadoDeJuego.LANZANDO_GATO:
			disparar_gato()
			return
		else:
			return
	
	bolas_restantes -=1
	
	bola_usada.emit(bolas_restantes) #Se conecta con la interfaz
	pedir_lanzar_bola.emit() #Se conecta con el disparador
	


func disparar_gato() -> void:
	estado_actual = EstadoDeJuego.LANZANDO_GATO
	lanzar_gato.emit() #Se conecta con el disparador
