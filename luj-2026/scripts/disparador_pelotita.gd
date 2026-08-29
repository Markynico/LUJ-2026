@icon("res://iconos_custom/tap.svg")
class_name DisparadorPelotita
extends Node2D

signal disparo #Se conecta con game manager
signal bola_escupida

@export var escena_pelotita_prueba : PackedScene
##multiplicador de fuerza que se aplica para empujar la pelotita, se usa para multiplicar a la velocidad inicial (velocidad inicial se da por que tan lejos esta el mouse del michi)

@export var fuerza_disparo : float = 2.0
##velocidad maxima a la que puede salir la bola
@export var velocidad_maxima : float = 1200.0
var velocidad_inicial : Vector2
var velocidad_congelada : Vector2
var posicion_mouse : Vector2
var bolitas_creadas : int = 0
var escala_gravedad_bola : float = 1.0
var fuerza_rebote_bola : float = 200.0


func _ready() -> void:
	var muestra : BolaDePelos = escena_pelotita_prueba.instantiate()
	escala_gravedad_bola = muestra.gravity_scale
	if muestra.tipo_pelotita and not muestra.tipo_pelotita.efectos.is_empty():
		fuerza_rebote_bola = muestra.tipo_pelotita.efectos[0].fuerza_rebote
	muestra.free()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		#esta moviendo el mouse
		#posicion_mouse = get_viewport().get_mouse_position()
		posicion_mouse = get_global_mouse_position()
		velocidad_inicial = (global_position - posicion_mouse) * fuerza_disparo #no lo normalizo para q justamente dispare mas fuerte si el mouse esta lejos
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			bolitas_creadas += 1
			print("BOLITA CREADA: " + str(bolitas_creadas))
			velocidad_congelada = velocidad_inicial
			disparo.emit()

func preparar_datos_disparo() -> DatosDisparo:
	var datos : DatosDisparo = DatosDisparo.new()
	datos.velocidad_inicial = (-velocidad_inicial).limit_length(velocidad_maxima)
	datos.gravedad *= escala_gravedad_bola
	datos.fuerza_rebote = fuerza_rebote_bola
	ReliquiasManager.al_preparar_disparo(datos)
	return datos


func escupir_bola () -> void:
		var tipo_pelotita = Global.cargador_de_pelotitas.pop_front()
		if tipo_pelotita == null:
			return
		var instancia : BolaDePelos = escena_pelotita_prueba.instantiate()
		instancia.tipo_pelotita = tipo_pelotita
		#add_child(instancia)
		#instancia.global_position = posicion_mouse
		#instancia.apply_impulse(preparar_datos_disparo().velocidad_inicial)
		Global.cargador_pelotitas_actualizado.emit() #esto ponerlo en ultima linea
		var datos : DatosDisparo
		var gravedad_default : float = ProjectSettings.get_setting("physics/2d/default_gravity")
		velocidad_inicial = velocidad_congelada
		datos = preparar_datos_disparo()
		instancia.gravity_scale = datos.gravedad.y / gravedad_default
		add_child(instancia)
		#instancia.global_position = posicion_mouse
		instancia.apply_impulse(datos.velocidad_inicial)
		bola_escupida.emit()
