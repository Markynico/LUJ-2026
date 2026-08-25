@tool
class_name FormaPath
extends Path2D

signal forma_cambiada

const INTERVALO_MUESTREO := 2.0

##distancia en pixeles entre un ovillo y el siguiente a lo largo de la curva
@export var separacion_ovillos : float = 50.0:
	set(valor):
		separacion_ovillos = max(valor, 1.0)
		actualizar()


func _ready() -> void:
	set_notify_transform(true)
	obtener_curva().changed.connect(actualizar)
	actualizar()


func _notification(que : int) -> void:
	if que == NOTIFICATION_TRANSFORM_CHANGED:
		actualizar()


func obtener_curva() -> Curve2D:
	if not curve:
		curve = Curve2D.new()
	if curve.bake_interval != INTERVALO_MUESTREO:
		curve.bake_interval = INTERVALO_MUESTREO
	return curve


func actualizar() -> void:
	forma_cambiada.emit()


func esta_cerrada() -> bool:
	var curva : Curve2D = obtener_curva()
	return curva.point_count > 2 and curva.get_point_position(0).is_equal_approx(curva.get_point_position(curva.point_count - 1))


func calcular_cantidad_ovillos(largo_total : float) -> int:
	return roundi(largo_total / separacion_ovillos)


func obtener_puntos() -> PackedVector2Array:
	var trazo : PackedVector2Array = global_transform * obtener_curva().tessellate()
	var largo : float = largo_de_polilinea(trazo)
	var cantidad : int = calcular_cantidad_ovillos(largo)
	var resultado : PackedVector2Array = PackedVector2Array()
	var total : int
	if cantidad == 0:
		return resultado
	total = cantidad if esta_cerrada() else cantidad + 1
	for i in total:
		resultado.append(punto_sobre_polilinea(trazo, largo * i / cantidad))
	return resultado


func largo_de_polilinea(trazo : PackedVector2Array) -> float:
	var largo : float = 0.0
	for i in trazo.size() - 1:
		largo += trazo[i].distance_to(trazo[i + 1])
	return largo


func punto_sobre_polilinea(trazo : PackedVector2Array, distancia : float) -> Vector2:
	var recorrido : float = 0.0
	var largo : float
	for i in trazo.size() - 1:
		largo = trazo[i].distance_to(trazo[i + 1])
		if distancia <= recorrido + largo or i == trazo.size() - 2:
			return trazo[i].lerp(trazo[i + 1], clampf((distancia - recorrido) / largo, 0.0, 1.0) if largo > 0.0 else 0.0)
		recorrido += largo
	return trazo[0] if not trazo.is_empty() else Vector2.ZERO


func obtener_datos() -> FormaData:
	var datos : FormaData = FormaData.new()
	datos.tipo = "path"
	datos.posicion = position
	datos.rotacion = rotation
	datos.separacion_ovillos = separacion_ovillos
	datos.escala = scale
	datos.curva = obtener_curva().duplicate()
	return datos


func aplicar_datos(datos : FormaData) -> void:
	position = datos.posicion
	rotation = datos.rotacion
	separacion_ovillos = datos.separacion_ovillos
	scale = datos.escala
	if datos.curva:
		curve = datos.curva.duplicate()
		curve.changed.connect(actualizar)
	actualizar()
