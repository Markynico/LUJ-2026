@icon("res://iconos_custom/gobot.svg")
class_name GameManager
extends Node
 
signal bola_usada(bolas_restantes : int)
signal gato_lanza_bola
signal lanzar_gato

enum EstadoDeJuego{
	ESPERANDO, #Al iniciar el nivel y elegir los poderes
	TIENDA, #Mientras se compra
	LANZANDO_BOLAS,
	LANZANDO_GATO,
	NIVEL_COMPLETADO,
	GAME_OVER
}

@export var gato : Gato
@export var bolas_maximas : int = 20

var bolas_restantes : int = 0:
	set(valor):
		bolas_restantes = valor
		bola_usada.emit(bolas_restantes)
var estado_actual : EstadoDeJuego = EstadoDeJuego.ESPERANDO

func _ready() -> void:
	bolas_restantes = bolas_maximas
	ReliquiasManager.al_empezar_nivel(self)
	estado_actual = EstadoDeJuego.LANZANDO_BOLAS
	
	gato.disparador_pelotitas.disparo.connect(disparar_bola)




#======= FUNCIONES ==========

func disparar_bola() -> void:
	if estado_actual != EstadoDeJuego.LANZANDO_BOLAS:
		return
	
	print("JUGANDO")
	if bolas_restantes > 0:
		bolas_restantes -= 1
		gato_lanza_bola.emit() #Se conecta con el disparador
	
	if bolas_restantes <= 0:
			cambiar_gato()


func cambiar_gato() -> void:
	estado_actual = EstadoDeJuego.LANZANDO_GATO
	lanzar_gato.emit() #Se conecta con el disparador
