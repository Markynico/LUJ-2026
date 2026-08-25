@tool
class_name FormaSpawn
extends Node2D

signal forma_cambiada

enum ManijaBase { CENTRO, ROTACION }

const COLOR_DIBUJO := Color(0.3, 0.9, 1.0, 0.9)
const GROSOR_DIBUJO := 2.0
const MARGEN_MANIJA_ROTACION := 40.0
const PASO_SNAP_ROTACION := deg_to_rad(45.0)

##distancia en pixeles entre un ovillo y el siguiente a lo largo del borde de la forma
@export var separacion_ovillos : float = 50.0:
	set(valor):
		separacion_ovillos = max(valor, 1.0)
		actualizar()


func _ready() -> void:
	set_notify_transform(true)
	actualizar()


func _notification(que : int) -> void:
	if que == NOTIFICATION_TRANSFORM_CHANGED:
		actualizar()


func _draw() -> void:
	if Engine.is_editor_hint() and usa_rotacion():
		draw_line(Vector2.ZERO, obtener_manija_rotacion(), COLOR_DIBUJO, 1.0)


func actualizar() -> void:
	queue_redraw()
	forma_cambiada.emit()


func obtener_puntos() -> PackedVector2Array:
	return PackedVector2Array()


func obtener_contorno() -> PackedVector2Array:
	return PackedVector2Array()


func contorno_cerrado() -> bool:
	return true


func esta_sobre_contorno(punto_local : Vector2, tolerancia : float) -> bool:
	var contorno := obtener_contorno()
	var segmentos := contorno.size() if contorno_cerrado() else contorno.size() - 1
	for i in segmentos:
		var desde := contorno[i]
		var hasta := contorno[(i + 1) % contorno.size()]
		if Geometry2D.get_closest_point_to_segment(punto_local, desde, hasta).distance_to(punto_local) <= tolerancia:
			return true
	return false


func usa_rotacion() -> bool:
	return true


func obtener_centro_manijas() -> Vector2:
	return Vector2.ZERO


func obtener_manijas() -> PackedVector2Array:
	var manijas := PackedVector2Array([obtener_centro_manijas()])
	if usa_rotacion():
		manijas.append(obtener_manija_rotacion())
	return manijas


func obtener_manija_rotacion() -> Vector2:
	return Vector2(0, -(obtener_radio_exterior() + MARGEN_MANIJA_ROTACION))


func obtener_radio_exterior() -> float:
	return 0.0


func empezar_arrastre_manija(indice : int) -> void:
	pass


func mover_manija(indice : int, posicion_local : Vector2, con_shift : bool, con_control : bool) -> void:
	match indice:
		ManijaBase.CENTRO:
			global_position += global_transform.basis_xform(posicion_local - obtener_centro_manijas())
		ManijaBase.ROTACION:
			rotation += obtener_manija_rotacion().angle_to(posicion_local)
			if con_shift:
				rotation = snappedf(rotation, PASO_SNAP_ROTACION)


func obtener_datos() -> FormaData:
	var datos := FormaData.new()
	datos.posicion = position
	datos.rotacion = rotation
	datos.escala = scale
	datos.separacion_ovillos = separacion_ovillos
	return datos


func aplicar_datos(datos : FormaData) -> void:
	position = datos.posicion
	rotation = datos.rotacion
	scale = datos.escala
	separacion_ovillos = datos.separacion_ovillos


func a_global(lista : PackedVector2Array) -> PackedVector2Array:
	return global_transform * lista


func puntos_sobre_poligono(vertices : PackedVector2Array) -> PackedVector2Array:
	var perimetro := 0.0
	for i in vertices.size():
		perimetro += vertices[i].distance_to(vertices[(i + 1) % vertices.size()])
	var cantidad := calcular_cantidad_ovillos(perimetro)
	if cantidad == 0:
		return PackedVector2Array()
	var separacion_real := perimetro / cantidad
	var puntos := PackedVector2Array()
	var recorrido := 0.0
	var siguiente := 0.0
	for i in vertices.size():
		var desde := vertices[i]
		var hasta := vertices[(i + 1) % vertices.size()]
		var largo := desde.distance_to(hasta)
		while siguiente < recorrido + largo - 0.001 and puntos.size() < cantidad:
			puntos.append(desde.lerp(hasta, (siguiente - recorrido) / largo))
			siguiente += separacion_real
		recorrido += largo
	return puntos


func calcular_cantidad_ovillos(largo_total : float) -> int:
	return roundi(largo_total / separacion_ovillos)
