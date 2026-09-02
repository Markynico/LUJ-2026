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
var restitucion_bola : float = 0.85
var friccion_bola : float = 0.0
var radio_bola : float = 11.0
var amortiguacion_angular_bola : float = 1.0


func _ready() -> void:
	var muestra : BolaDePelos = escena_pelotita_prueba.instantiate()
	var colision : CollisionShape2D = muestra.get_node_or_null("CollisionShape2D")
	escala_gravedad_bola = muestra.gravity_scale
	if muestra.tipo_pelotita and not muestra.tipo_pelotita.efectos.is_empty():
		fuerza_rebote_bola = muestra.tipo_pelotita.efectos[0].fuerza_rebote
	restitucion_bola = muestra.amortiguacion_rebote
	if muestra.physics_material_override:
		friccion_bola = muestra.physics_material_override.friction
	if colision and colision.shape is CircleShape2D:
		radio_bola = colision.shape.radius
	amortiguacion_angular_bola = ProjectSettings.get_setting("physics/2d/default_angular_damp", 1.0) + muestra.angular_damp
	muestra.free()


func _process(delta : float) -> void:
	posicion_mouse = get_global_mouse_position()
	velocidad_inicial = (global_position - posicion_mouse) * fuerza_disparo #no lo normalizo para q justamente dispare mas fuerte si el mouse esta lejos


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			bolitas_creadas += 1
			print("BOLITA CREADA: " + str(bolitas_creadas))
			velocidad_congelada = velocidad_inicial
			disparo.emit()

func preparar_datos_disparo() -> DatosDisparo:
	var datos : DatosDisparo = DatosDisparo.new()
	datos.tipo_pelotita = Global.cargador_de_pelotitas.front() if not Global.cargador_de_pelotitas.is_empty() else null
	datos.velocidad_inicial = (-velocidad_inicial).limit_length(velocidad_maxima)
	datos.gravedad *= escala_gravedad_bola
	datos.fuerza_rebote = fuerza_rebote_bola
	datos.restitucion = restitucion_bola
	datos.friccion = friccion_bola
	datos.radio = radio_bola
	datos.amortiguacion_angular = amortiguacion_angular_bola
	ReliquiasManager.al_preparar_disparo(datos)
	return datos


func escupir_bola () -> void: #se llama desde el animation player del gato
		var tipo_pelotita = Global.cargador_de_pelotitas.pop_front()
		if tipo_pelotita == null:
			return
		var instancia : BolaDePelos = escena_pelotita_prueba.instantiate()
		instancia.tipo_pelotita = tipo_pelotita
		var datos : DatosDisparo
		var gravedad_default : float = ProjectSettings.get_setting("physics/2d/default_gravity")
		velocidad_inicial = velocidad_congelada
		datos = preparar_datos_disparo()
		instancia.gravity_scale = datos.gravedad.y / gravedad_default
		instancia.top_level = true
		add_child(instancia)
		instancia.global_position = global_position
		#instancia.global_position = posicion_mouse
		instancia.apply_impulse(datos.velocidad_inicial)
		instancia.velocidad_constante = datos.velocidad_constante
		instancia.rapidez_constante = datos.velocidad_inicial.length()
		EstadisticasRun.registrar_bola_disparada()
		ReliquiasManager.al_disparar()
		Global.cargador_pelotitas_actualizado.emit() #voy a probar avisarle al game manaeger q salga del estado esperando bola
		bola_escupida.emit()
