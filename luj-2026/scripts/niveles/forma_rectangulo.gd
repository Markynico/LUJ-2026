@tool
class_name FormaRectangulo
extends FormaSpawn

enum Manija { CENTRO, ROTACION, ARRIBA_IZQUIERDA, ARRIBA_DERECHA, ABAJO_DERECHA, ABAJO_IZQUIERDA }

##ancho y alto del rectangulo, centrado en la posicion del nodo
@export var tamaño : Vector2 = Vector2(200, 100):
	set(valor):
		tamaño = valor.abs()
		actualizar()


func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	super()
	var vertices := obtener_vertices()
	vertices.append(vertices[0])
	draw_polyline(vertices, color_dibujo, grosor_dibujo)


func obtener_vertices() -> PackedVector2Array:
	var mitad := tamaño * 0.5
	return PackedVector2Array([
		Vector2(-mitad.x, -mitad.y),
		Vector2(mitad.x, -mitad.y),
		Vector2(mitad.x, mitad.y),
		Vector2(-mitad.x, mitad.y),
	])


func obtener_puntos() -> PackedVector2Array:
	return puntos_sobre_poligono(obtener_vertices())


func obtener_manijas() -> PackedVector2Array:
	var manijas := super()
	manijas.append_array(obtener_vertices())
	return manijas


func mover_manija(indice : int, posicion_local : Vector2) -> void:
	if indice <= Manija.ROTACION:
		super(indice, posicion_local)
		return
	tamaño = posicion_local.abs() * 2.0


func obtener_datos() -> FormaData:
	var datos := super()
	datos.tipo = "rectangulo"
	datos.tamaño = tamaño
	return datos


func aplicar_datos(datos : FormaData) -> void:
	super(datos)
	tamaño = datos.tamaño
