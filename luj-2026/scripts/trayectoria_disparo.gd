class_name TrayectoriaDisparo
extends Line2D

@export var disparador : DisparadorPelotita
##shape cast con la forma de la bola que frena la linea donde frenaria la bola
@export var detector : ShapeCast2D
##color del circulo que marca donde impacta la bola
@export var color_impacto : Color = Color.WHITE

@export var mostrar_camino_previo : bool = false
@export var color_camino_previo : Color = Color(0.4, 0.75, 1.0, 0.45)
##segundos del fade de la trayectoria cuando el mouse esta sobre la ui y el click no dispara
@export var duracion_fade_ui : float = 0.15

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
			ajustar_datos_para_gato(datos)
		puntos_camino_previo = calcular_puntos(datos)
		queue_redraw()

func _process(delta : float) -> void:
	var sobre_ui : bool = get_viewport().gui_get_hovered_control() != null
	visible = hay_algo_para_disparar()
	if visible:
		dibujar_trayectoria()
		modulate.a = move_toward(modulate.a, 0.0 if sobre_ui else 1.0, delta / maxf(duracion_fade_ui, 0.01))

func ajustar_datos_para_gato(datos : DatosDisparo) -> void:
	datos.velocidad_inicial = -gato.velocidad_inicial
	datos.gravedad = Vector2(0, ProjectSettings.get_setting("physics/2d/default_gravity")) * gato.gravity_scale


func hay_algo_para_disparar() -> bool:
	if not gato or not gato.game_manager:
		return true
	if gato.listo_para_lanzar:
		return true
	if gato.esta_escupiendo():
		return false
	if not get_tree().get_nodes_in_group("bolas_de_pelos").is_empty():
		return false
	return gato.game_manager.estado_actual == GameManager.EstadoDeJuego.LANZANDO_BOLAS and gato.game_manager.bolas_restantes > 0

func dibujar_trayectoria() -> void:
	var datos : DatosDisparo = disparador.preparar_datos_disparo()
	if gato and gato.listo_para_lanzar:
		ajustar_datos_para_gato(datos)
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
	var cuerpo : Node
	var fuerza_rebote : float
	if gato and gato.listo_para_lanzar:
		posicion = gato.global_position
	if not detector:
		return puntos
	detector.clear_exceptions()
	detector.global_position = posicion
	puntos.append(posicion)
	for i in datos.pasos:
		velocidad += datos.gravedad * datos.intervalo
		movimiento = velocidad * datos.intervalo
		detector.target_position = movimiento
		detector.clear_exceptions()
		detector.force_shapecast_update()
		if detector.is_colliding() and puede_atravesar(detector.get_collider(0), detector.get_collider_shape(0), velocidad):
			cuerpo = detector.get_collider(0)
			detector.add_exception(cuerpo)
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
			fuerza_rebote = datos.fuerza_rebote
			cuerpo = detector.get_collider(0)
			if cuerpo is Ovillo and cuerpo.tipo_ovillo:
				fuerza_rebote += cuerpo.tipo_ovillo.rebote_extra
			velocidad = velocidad.slide(normal) * datos.factor_friccion + normal * fuerza_rebote
			posicion += normal * 0.5
		else:
			posicion += movimiento
			puntos.append(posicion)
		detector.global_position = posicion
	detector.clear_exceptions()
	return puntos


func puede_atravesar(colisionador : Object, indice_forma : int, velocidad : Vector2) -> bool:
	var id_dueño : int
	var nodo_forma : CollisionShape2D
	var direccion_bloqueo : Vector2
	if not colisionador is CollisionObject2D:
		return false
	id_dueño = colisionador.shape_find_owner(indice_forma)
	nodo_forma = colisionador.shape_owner_get_owner(id_dueño) as CollisionShape2D
	if nodo_forma == null or not nodo_forma.one_way_collision:
		return false
	direccion_bloqueo = nodo_forma.global_transform.basis_xform(nodo_forma.one_way_collision_direction).normalized()
	return velocidad.dot(direccion_bloqueo) <= 0.0
