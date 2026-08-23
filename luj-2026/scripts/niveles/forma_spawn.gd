@tool
class_name FormaSpawn
extends Node2D

signal forma_cambiada

enum ManijaBase { CENTRO, ROTACION }

##distancia en pixeles entre un ovillo y el siguiente a lo largo del borde de la forma
@export var separacion_ovillos : float = 50.0:
	set(valor):
		separacion_ovillos = max(valor, 1.0)
		actualizar()
##color del contorno que se dibuja en el editor
@export var color_dibujo : Color = Color(0.3, 0.9, 1.0, 0.9):
	set(valor):
		color_dibujo = valor
		queue_redraw()
@export var grosor_dibujo : float = 2.0
##distancia desde el centro a la que se dibuja la manija para rotar la forma
@export var distancia_manija_rotacion : float = 80.0


func _ready() -> void:
	actualizar()


func _draw() -> void:
	if Engine.is_editor_hint():
		draw_line(Vector2.ZERO, obtener_manija_rotacion(), color_dibujo, 1.0)


func actualizar() -> void:
	queue_redraw()
	forma_cambiada.emit()


func obtener_puntos() -> PackedVector2Array:
	return PackedVector2Array()


func obtener_manijas() -> PackedVector2Array:
	return PackedVector2Array([Vector2.ZERO, obtener_manija_rotacion()])


func obtener_manija_rotacion() -> Vector2:
	return Vector2(0, -distancia_manija_rotacion)


func mover_manija(indice : int, posicion_local : Vector2) -> void:
	match indice:
		ManijaBase.CENTRO:
			position += posicion_local.rotated(rotation)
		ManijaBase.ROTACION:
			rotation += obtener_manija_rotacion().angle_to(posicion_local)


func obtener_datos() -> FormaData:
	var datos := FormaData.new()
	datos.posicion = position
	datos.rotacion = rotation
	datos.separacion_ovillos = separacion_ovillos
	return datos


func aplicar_datos(datos : FormaData) -> void:
	position = datos.posicion
	rotation = datos.rotacion
	separacion_ovillos = datos.separacion_ovillos


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
