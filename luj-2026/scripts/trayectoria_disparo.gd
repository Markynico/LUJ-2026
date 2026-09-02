class_name TrayectoriaDisparo
extends Line2D

@export var disparador : DisparadorPelotita
##shape cast con la forma de la bola que frena la linea donde frenaria la bola
@export var detector : ShapeCast2D
##color del circulo que marca donde impacta la bola
@export var color_impacto : Color = Color.WHITE

##deja un rastro en vivo de cada bola disparada, lo activa la tapita de lapicera
@export var mostrar_camino_previo : bool = false
##escena del rastro que sigue a cada bola
@export var escena_rastro : PackedScene = preload("uid://crastrobola0a1")
##segundos del fade de los rastros cuando arranca el siguiente disparo
@export var duracion_fade_rastro : float = 0.5
##segundos del fade de la trayectoria cuando el mouse esta sobre la ui y el click no dispara
@export var duracion_fade_ui : float = 0.15

var hay_impacto : bool = false
var centro_impacto : Vector2
var gato : Gato
var rastros : Array[RastroBola] = []
var tipo_pelotita_simulada : PelotitaBase

func _ready() -> void:
	gato = disparador.get_parent() as Gato
	if disparador:
		disparador.disparo.connect(desvanecer_rastros)
	get_tree().node_added.connect(al_agregar_nodo)

func al_agregar_nodo(nodo : Node) -> void:
	if mostrar_camino_previo and nodo is BolaDePelos:
		crear_rastro.call_deferred(nodo)

func crear_rastro(bola : BolaDePelos) -> void:
	var rastro : RastroBola
	if not is_instance_valid(bola) or not escena_rastro:
		return
	rastro = escena_rastro.instantiate()
	disparador.add_child(rastro)
	rastro.seguir(bola)
	rastros.append(rastro)

func desvanecer_rastros() -> void:
	var tween : Tween
	for rastro in rastros:
		if not is_instance_valid(rastro):
			continue
		tween = rastro.create_tween()
		tween.tween_property(rastro, "modulate:a", 0.0, duracion_fade_rastro)
		tween.tween_callback(rastro.queue_free)
	rastros.clear()

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
	if hay_impacto:
		draw_circle(to_local(centro_impacto), radio_de_la_bola(), color_impacto)

func radio_de_la_bola() -> float:
	return detector.shape.radius if detector and detector.shape is CircleShape2D else 12.0

func calcular_puntos(datos : DatosDisparo) -> PackedVector2Array:
	var puntos : PackedVector2Array = PackedVector2Array()
	var posicion : Vector2 = disparador.global_position
	var velocidad : Vector2 = datos.velocidad_inicial
	var rebotes_restantes : int = datos.rebotes
	var velocidad_angular : float = 0.0
	var movimiento : Vector2
	var normal : Vector2
	var tangente : Vector2
	var velocidad_normal : float
	var velocidad_tangencial : float
	var impulso_normal : float
	var impulso_friccion : float
	var deslizamiento : float
	var cuerpo : Node
	var impulso_extra : float
	var frontalidad : float
	if gato and gato.listo_para_lanzar:
		posicion = gato.global_position
	if not detector:
		return puntos
	tipo_pelotita_simulada = datos.tipo_pelotita
	detector.clear_exceptions()
	detector.global_position = posicion
	puntos.append(posicion)
	for i in datos.pasos:
		velocidad += datos.gravedad * datos.intervalo
		if datos.velocidad_constante and not velocidad.is_zero_approx():
			velocidad = velocidad.normalized() * datos.velocidad_inicial.length()
		velocidad_angular *= maxf(0.0, 1.0 - datos.amortiguacion_angular * datos.intervalo)
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
			tangente = Vector2(-normal.y, normal.x)
			velocidad_normal = velocidad.dot(normal)
			velocidad_tangencial = velocidad.dot(tangente)
			impulso_normal = maxf(0.0, -velocidad_normal)
			deslizamiento = velocidad_tangencial - velocidad_angular * datos.radio
			impulso_friccion = clampf(-deslizamiento / 3.0, -datos.friccion * impulso_normal, datos.friccion * impulso_normal)
			velocidad_tangencial += impulso_friccion
			velocidad_angular -= 2.0 * impulso_friccion / datos.radio
			impulso_extra = 0.0
			cuerpo = detector.get_collider(0)
			if cuerpo is Ovillo:
				impulso_extra = datos.fuerza_rebote
				if cuerpo.tipo_ovillo:
					impulso_extra += cuerpo.tipo_ovillo.rebote_extra * ReliquiasManager.multiplicador_rebote()
			frontalidad = clampf(-velocidad.normalized().dot(normal), 0.0, 1.0)
			if datos.velocidad_constante:
				velocidad = velocidad.bounce(normal).normalized() * datos.velocidad_inicial.length()
				velocidad_angular = 0.0
			else:
				velocidad = tangente * velocidad_tangencial + normal * (impulso_normal * datos.restitucion + impulso_extra * frontalidad)
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
	if colisionador is Ovillo and colisionador.simular_impacto(tipo_pelotita_simulada).atravesar:
		return true
	id_dueño = colisionador.shape_find_owner(indice_forma)
	nodo_forma = colisionador.shape_owner_get_owner(id_dueño) as CollisionShape2D
	if nodo_forma == null or not nodo_forma.one_way_collision:
		return false
	direccion_bloqueo = nodo_forma.global_transform.basis_xform(nodo_forma.one_way_collision_direction).normalized()
	return velocidad.dot(direccion_bloqueo) <= 0.0
