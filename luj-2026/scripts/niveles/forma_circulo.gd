@tool
class_name FormaCirculo
extends FormaSpawn

enum Manija { CENTRO, ROTACION, RADIO }

const SEGMENTOS_DIBUJO := 64

##radio del circulo, centrado en la posicion del nodo
@export var radio : float = 100.0:
	set(valor):
		radio = max(valor, 1.0)
		actualizar()


func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	super()
	draw_arc(Vector2.ZERO, radio, 0.0, TAU, SEGMENTOS_DIBUJO, COLOR_DIBUJO, GROSOR_DIBUJO)


func obtener_contorno() -> PackedVector2Array:
	var contorno := PackedVector2Array()
	for i in SEGMENTOS_DIBUJO:
		contorno.append(Vector2.from_angle(TAU * i / SEGMENTOS_DIBUJO) * radio)
	return contorno


func obtener_radio_exterior() -> float:
	return radio


func obtener_puntos() -> PackedVector2Array:
	return puntos_sobre_poligono(a_global(obtener_contorno()))


func obtener_manijas() -> PackedVector2Array:
	var manijas := super()
	manijas.append(Vector2(radio, 0))
	return manijas


func mover_manija(indice : int, posicion_local : Vector2, con_shift : bool, con_control : bool) -> void:
	if indice == Manija.RADIO:
		radio = posicion_local.length()
		return
	super(indice, posicion_local, con_shift, con_control)


func obtener_datos() -> FormaData:
	var datos := super()
	datos.tipo = "circulo"
	datos.radio = radio
	return datos


func aplicar_datos(datos : FormaData) -> void:
	super(datos)
	radio = datos.radio
