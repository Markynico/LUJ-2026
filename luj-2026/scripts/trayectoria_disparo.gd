class_name TrayectoriaDisparo
extends Line2D

@export var disparador : DisparadorPelotita
##shape cast con la forma de la bola que frena la linea donde frenaria la bola
@export var detector : ShapeCast2D
##color del circulo que marca donde impacta la bola
@export var color_impacto : Color = Color.WHITE

@export var mostrar_camino_previo : bool = false
@export var color_camino_previo : Color = Color(0.4, 0.75, 1.0, 0.45)

var hay_impacto : bool = false
var centro_impacto : Vector2
var gato : Gato
var puntos_camino_previo : PackedVector2Array = PackedVector2Array()

func _ready() -> void:
	gato = disparador.get_parent() as Gato
	if disparador:
		disparador.disparo.connect(_on_disparo_realizado)

func _on_disparo_realizado() -> void:
	if mostrar_camino_previo:
		var datos : DatosDisparo = disparador.preparar_datos_disparo()
		if gato and gato.listo_para_lanzar:
			datos.velocidad_inicial = -gato.velocidad_inicial
		puntos_camino_previo = calcular_puntos(datos)
		queue_redraw()

func _process(_delta : float) -> void:
	visible = hay_algo_para_disparar()
	if visible:
		dibujar_trayectoria()

func hay_algo_para_disparar() -> bool:
	if not gato or not gato.game_manager:
		return true
	if gato.listo_para_lanzar:
		return true
	return gato.game_manager.estado_actual == GameManager.EstadoDeJuego.LANZANDO_BOLAS and gato.game_manager.bolas_restantes > 0

func dibujar_trayectoria() -> void:
	var datos : DatosDisparo = disparador.preparar_datos_disparo()
	if gato and gato.listo_para_lanzar:
		datos.velocidad_inicial = -gato.velocidad_inicial
	clear_points()
	hay_impacto = false
	for punto in calcular_puntos(datos):
		add_point(to_local(punto))
	queue_redraw()

func _draw() -> void:
	if mostrar_camino_previo and puntos_camino_previo.size() > 1:
		var puntos_locales := PackedVector2Array()
		for p in puntos_camino_previo:
			puntos_locales.append(to_local(p))
		draw_polyline(puntos_locales, color_camino_previo, 2.5, true)
	
	if hay_impacto:
		draw_circle(to_local(centro_impacto), radio_de_la_bola(), color_impacto)

func radio_de_la_bola() -> float:
	return detector.shape.radius if detector and detector.shape is CircleShape2D else 12.0

func calcular_puntos(datos : DatosDisparo) -> PackedVector2Array:
	var puntos : PackedVector2Array = PackedVector2Array()
	var posicion : Vector2 = disparador.global_position
	var velocidad : Vector2 = datos.velocidad_inicial
	var rebotes_restantes : int = datos.rebotes
	var movimiento : Vector2
	var normal : Vector2
	if not detector:
		return puntos
	detector.global_position = posicion
	puntos.append(posicion)
	for i in datos.pasos:
		velocidad += datos.gravedad * datos.intervalo
		movimiento = velocidad * datos.intervalo
		detector.target_position = movimiento
		detector.force_shapecast_update()
		if detector.is_colliding():
			posicion += movimiento * detector.get_closest_collision_safe_fraction()
			puntos.append(posicion)
			centro_impacto = posicion
			hay_impacto = true
			if rebotes_restantes <= 0:
				break
			rebotes_restantes -= 1
			normal = detector.get_collision_normal(0)
			velocidad = velocidad.slide(normal) * datos.factor_friccion + normal * datos.fuerza_rebote
			posicion += normal * 0.5
		else:
			posicion += movimiento
			puntos.append(posicion)
		detector.global_position = posicion
	return puntos
