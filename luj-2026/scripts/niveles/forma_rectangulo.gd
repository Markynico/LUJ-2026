@tool
class_name FormaRectangulo
extends FormaSpawn

enum Manija { CENTRO, ROTACION, ARRIBA_IZQUIERDA, ARRIBA_DERECHA, ABAJO_DERECHA, ABAJO_IZQUIERDA }

var ancla_global : Vector2
var direccion_diagonal : Vector2

##ancho y alto del rectangulo, centrado en la posicion del nodo
@export var tamaño : Vector2 = Vector2(200, 100):
	set(valor):
		tamaño = valor.abs()
		actualizar()


func _draw() -> void:
	var vertices : PackedVector2Array
	if not Engine.is_editor_hint():
		return
	super()
	vertices = obtener_vertices()
	vertices.append(vertices[0])
	draw_polyline(vertices, COLOR_DIBUJO, GROSOR_DIBUJO)


func obtener_vertices() -> PackedVector2Array:
	var mitad : Vector2 = tamaño * 0.5
	return PackedVector2Array([
		Vector2(-mitad.x, -mitad.y),
		Vector2(mitad.x, -mitad.y),
		Vector2(mitad.x, mitad.y),
		Vector2(-mitad.x, mitad.y),
	])


func obtener_contorno() -> PackedVector2Array:
	return obtener_vertices()


func obtener_radio_exterior() -> float:
	return tamaño.y * 0.5


func obtener_puntos() -> PackedVector2Array:
	return puntos_sobre_poligono(a_global(obtener_vertices()))


func obtener_manijas() -> PackedVector2Array:
	var manijas : PackedVector2Array = super()
	manijas.append_array(obtener_vertices())
	return manijas


func empezar_arrastre_manija(indice : int) -> void:
	var esquina : Vector2
	if indice < Manija.ARRIBA_IZQUIERDA:
		return
	esquina = obtener_vertices()[indice - Manija.ARRIBA_IZQUIERDA]
	ancla_global = to_global(-esquina)
	direccion_diagonal = esquina.normalized()


func mover_manija(indice : int, posicion_local : Vector2, con_shift : bool, con_control : bool) -> void:
	if indice <= Manija.ROTACION:
		super(indice, posicion_local, con_shift, con_control)
		return
	if con_control:
		escalar_desde_centro(posicion_local, con_shift)
	else:
		escalar_desde_ancla(posicion_local, con_shift)


func escalar_desde_centro(posicion_local : Vector2, proporcional : bool) -> void:
	var mitad : Vector2 = posicion_local
	if proporcional:
		mitad = proyectar_sobre_diagonal(mitad)
	tamaño = mitad.abs() * 2.0


func escalar_desde_ancla(posicion_local : Vector2, proporcional : bool) -> void:
	var opuesta : Vector2 = to_local(ancla_global)
	var diagonal : Vector2 = posicion_local - opuesta
	if proporcional:
		diagonal = proyectar_sobre_diagonal(diagonal)
	position += (opuesta + diagonal * 0.5).rotated(rotation)
	tamaño = diagonal.abs()


func proyectar_sobre_diagonal(vector : Vector2) -> Vector2:
	return direccion_diagonal * vector.dot(direccion_diagonal)


func obtener_datos() -> FormaData:
	var datos : FormaData = super()
	datos.tipo = "rectangulo"
	datos.tamaño = tamaño
	return datos


func aplicar_datos(datos : FormaData) -> void:
	super(datos)
	tamaño = datos.tamaño
