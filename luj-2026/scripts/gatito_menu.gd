class_name GatitoMenu
extends Node2D

@export var color_pelaje: Color = Color(0.96, 0.65, 0.32) # Naranja atigrado / cálido
@export var color_oreja_interna: Color = Color(1.0, 0.78, 0.8)
@export var color_ojos: Color = Color(0.95, 0.95, 0.98)
@export var color_pupila: Color = Color(0.12, 0.35, 0.28) # Verde esmeralda felino
@export var color_nariz: Color = Color(0.95, 0.5, 0.6)
@export var color_hocico: Color = Color(1.0, 0.92, 0.82)
@export var color_detalles: Color = Color(0.2, 0.2, 0.25) # Bigotes y líneas

@export var radio_pupila_max: float = 12.0
@export var suavizado_mirada: float = 15.0
@export var inclinacion_maxima_rad: float = 0.15

# Posiciones locales relativas a la cabeza
var pos_ojo_izq: Vector2 = Vector2(-34, -12)
var pos_ojo_der: Vector2 = Vector2(34, -12)
var radio_ojo: float = 20.0
var radio_pupila: float = 9.0

# Desplazamiento actual de las pupilas
var _offset_pupilas: Vector2 = Vector2.ZERO
var _offset_objetivo: Vector2 = Vector2.ZERO

# Parpadeo
var _esta_parpadeando: bool = false
var _tiempo_parpadeo: float = 0.0
var _temporizador_proximo_parpadeo: float = 3.0
var _cabeza_rotacion_objetivo: float = 0.0

func _ready() -> void:
	_reset_timer_parpadeo()

func _process(delta: float) -> void:
	# 1. Calcular dirección hacia el mouse global
	var pos_mouse_global = get_global_mouse_position()
	var pos_cabeza_global = global_position
	var dir_hacia_mouse = (pos_mouse_global - pos_cabeza_global)
	var distancia = dir_hacia_mouse.length()
	
	if distancia > 0.1:
		var dir_normalizada = dir_hacia_mouse.normalized()
		# Limitar desplazamiento proporcional a la distancia del mouse
		var factor_distancia = clampf(distancia / 300.0, 0.0, 1.0)
		_offset_objetivo = dir_normalizada * (radio_pupila_max * factor_distancia)
		_cabeza_rotacion_objetivo = clampf(dir_normalizada.x * inclinacion_maxima_rad, -inclinacion_maxima_rad, inclinacion_maxima_rad)
	else:
		_offset_objetivo = Vector2.ZERO
		_cabeza_rotacion_objetivo = 0.0
	
	# Interpolar suavemente
	_offset_pupilas = _offset_pupilas.lerp(_offset_objetivo, suavizado_mirada * delta)
	rotation = lerpf(rotation, _cabeza_rotacion_objetivo, suavizado_mirada * 0.5 * delta)
	
	# 2. Control de parpadeo
	_tiempo_parpadeo -= delta
	if _tiempo_parpadeo <= 0.0:
		if not _esta_parpadeando:
			# Iniciar parpadeo
			_esta_parpadeando = true
			_tiempo_parpadeo = 0.12 # Duración del parpadeo
		else:
			# Terminar parpadeo y programar el próximo
			_esta_parpadeando = false
			_reset_timer_parpadeo()
	
	queue_redraw()

func _reset_timer_parpadeo() -> void:
	_tiempo_parpadeo = randf_range(2.5, 6.0)

func _draw() -> void:
	# 1. Orejas
	_dibujar_oreja(Vector2(-55, -45), Vector2(-75, -95), Vector2(-25, -60))
	_dibujar_oreja(Vector2(55, -45), Vector2(75, -95), Vector2(25, -60))
	
	# 2. Cabeza principal (círculo / óvalo suavizado)
	draw_circle(Vector2(0, 0), 65.0, color_pelaje)
	# Mejillas
	draw_circle(Vector2(-35, 18), 32.0, color_pelaje)
	draw_circle(Vector2(35, 18), 32.0, color_pelaje)
	
	# Mechones de pelaje en las mejillas
	_dibujar_mechon(Vector2(-65, 15), Vector2(-80, 20), Vector2(-60, 30))
	_dibujar_mechon(Vector2(65, 15), Vector2(80, 20), Vector2(60, 30))
	
	# 3. Rayitas atigradas decorativas en la frente
	draw_line(Vector2(-15, -42), Vector2(-10, -26), color_detalles.darkened(0.2), 3.0, true)
	draw_line(Vector2(0, -48), Vector2(0, -28), color_detalles.darkened(0.2), 3.5, true)
	draw_line(Vector2(15, -42), Vector2(10, -26), color_detalles.darkened(0.2), 3.0, true)
	
	# 4. Ojos
	_dibujar_ojo(pos_ojo_izq)
	_dibujar_ojo(pos_ojo_der)
	
	# 5. Hocico y Nariz
	# Base hocico (blanco/crema)
	draw_circle(Vector2(-12, 22), 16.0, color_hocico)
	draw_circle(Vector2(12, 22), 16.0, color_hocico)
	
	# Nariz triangular
	var puntos_nariz = PackedVector2Array([
		Vector2(-10, 10),
		Vector2(10, 10),
		Vector2(0, 19)
	])
	draw_colored_polygon(puntos_nariz, color_nariz)
	
	# Boca (curvas sutiles)
	draw_arc(Vector2(-8, 22), 10.0, 0.2, PI * 0.8, 16, color_detalles, 2.5, true)
	draw_arc(Vector2(8, 22), 10.0, 0.2, PI * 0.8, 16, color_detalles, 2.5, true)
	
	# 6. Bigotes
	# Lado Izquierdo
	draw_line(Vector2(-25, 18), Vector2(-85, 10), color_detalles, 2.0, true)
	draw_line(Vector2(-25, 23), Vector2(-90, 26), color_detalles, 2.0, true)
	draw_line(Vector2(-25, 28), Vector2(-80, 42), color_detalles, 2.0, true)
	
	# Lado Derecho
	draw_line(Vector2(25, 18), Vector2(85, 10), color_detalles, 2.0, true)
	draw_line(Vector2(25, 23), Vector2(90, 26), color_detalles, 2.0, true)
	draw_line(Vector2(25, 28), Vector2(80, 42), color_detalles, 2.0, true)

func _dibujar_oreja(p1: Vector2, p2: Vector2, p3: Vector2) -> void:
	var oreja_externa = PackedVector2Array([p1, p2, p3])
	draw_colored_polygon(oreja_externa, color_pelaje)
	
	# Oreja interna (más pequeña)
	var centro = (p1 + p2 + p3) / 3.0
	var oreja_interna = PackedVector2Array([
		p1.lerp(centro, 0.3),
		p2.lerp(centro, 0.2),
		p3.lerp(centro, 0.3)
	])
	draw_colored_polygon(oreja_interna, color_oreja_interna)

func _dibujar_mechon(p1: Vector2, p2: Vector2, p3: Vector2) -> void:
	draw_colored_polygon(PackedVector2Array([p1, p2, p3]), color_pelaje)

func _dibujar_ojo(pos_ojo: Vector2) -> void:
	if _esta_parpadeando:
		# Dibujar línea curva de ojo cerrado
		draw_arc(pos_ojo + Vector2(0, 4), radio_ojo * 0.8, PI * 1.1, PI * 1.9, 16, color_detalles, 3.5, true)
		return
	
	# Fondo esclera del ojo
	draw_circle(pos_ojo, radio_ojo, color_ojos)
	# Contorno del ojo
	draw_arc(pos_ojo, radio_ojo, 0, TAU, 32, color_detalles, 2.0, true)
	
	# Pupila (con posición que sigue el cursor)
	var pos_pupila = pos_ojo + _offset_pupilas
	draw_circle(pos_pupila, radio_pupila, color_pupila)
	
	# Brillo / Reflejo de luz en el ojo
	draw_circle(pos_pupila + Vector2(-3, -3), radio_pupila * 0.38, Color.WHITE)
	draw_circle(pos_pupila + Vector2(2, 2), radio_pupila * 0.18, Color(1, 1, 1, 0.7))
