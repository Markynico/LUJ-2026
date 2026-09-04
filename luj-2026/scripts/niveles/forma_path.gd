@tool
class_name FormaPath
extends Path2D

signal forma_cambiada

const INTERVALO_MUESTREO := 2.0

##distancia en pixeles entre un ovillo y el siguiente a lo largo de la curva
@export var separacion_ovillos : int = 50:
	set(valor):
		separacion_ovillos = maxi(valor, 1)
		actualizar()

@export_group("Simetria")
##crea y mantiene clones espejados de este path cuando la simetria del editor esta activa
@export var usar_simetria : bool = false

@export_group("Repeticiones")
##copias del path a cada lado del original
@export_range(0, 20, 1) var repeticiones : int = 0:
	set(valor):
		repeticiones = maxi(valor, 0)
		actualizar()
##distancia entre una copia y la siguiente
@export var separacion_repeticiones : int = 80:
	set(valor):
		separacion_repeticiones = maxi(valor, 1)
		actualizar()
##eje local del path sobre el que se desplazan las copias
@export_enum("Horizontal", "Vertical") var eje_repeticiones : int = 1:
	set(valor):
		eje_repeticiones = valor
		actualizar()
##desplazamiento extra que se acumula en cada copia, ademas del eje
@export var offset_repeticiones : Vector2 = Vector2.ZERO:
	set(valor):
		offset_repeticiones = valor
		actualizar()
##las copias alternadas corren sus ovillos medio paso, como ladrillos
@export var efecto_ladrillo : bool = false:
	set(valor):
		efecto_ladrillo = valor
		actualizar()

@export_group("Desplazamiento")
##velocidad en pixeles por segundo con la que los ovillos recorren la curva, 0 = quietos
@export var velocidad_desplazamiento : float = 0.0
##invierte el sentido del desplazamiento
@export var invertir_desplazamiento : bool = false
##las repeticiones alternan el sentido del desplazamiento entre si
@export var alternar_direccion_repeticiones : bool = false

@export_group("Huecos")
##indices de los ovillos del path que no aparecen, se editan con la herramienta de seleccion de ovillos
@export var huecos : PackedInt32Array = PackedInt32Array():
	set(valor):
		huecos = valor
		actualizar()

var fase_desplazamiento : float = 0.0


func _ready() -> void:
	set_notify_transform(true)
	obtener_curva().changed.connect(actualizar)
	actualizar()


func _notification(que : int) -> void:
	if que == NOTIFICATION_TRANSFORM_CHANGED:
		actualizar()


func _process(delta : float) -> void:
	if (Engine.is_editor_hint() and not FormaSpawn.previsualizar_movimiento) or velocidad_desplazamiento == 0.0:
		return
	fase_desplazamiento += velocidad_desplazamiento * (-1.0 if invertir_desplazamiento else 1.0) * delta
	forma_cambiada.emit()


func obtener_curva() -> Curve2D:
	if not curve:
		curve = Curve2D.new()
	if curve.bake_interval != INTERVALO_MUESTREO:
		curve.bake_interval = INTERVALO_MUESTREO
	return curve


func actualizar() -> void:
	queue_redraw()
	forma_cambiada.emit()


func _draw() -> void:
	var trazo : PackedVector2Array
	if not Engine.is_editor_hint() or repeticiones == 0:
		return
	trazo = obtener_curva().tessellate()
	if trazo.size() < 2:
		return
	for desplazamiento in desplazamientos_de_repeticiones():
		if desplazamiento == Vector2.ZERO:
			continue
		draw_polyline(trazo_desplazado(trazo, desplazamiento), Color(0.3, 0.9, 1.0, 0.5), 2.0)


func desplazamientos_de_repeticiones() -> Array[Vector2]:
	var lista : Array[Vector2] = [Vector2.ZERO]
	var direccion : Vector2 = Vector2.RIGHT if eje_repeticiones == 0 else Vector2.DOWN
	var paso : Vector2 = direccion * float(separacion_repeticiones) + offset_repeticiones
	for i in range(1, repeticiones + 1):
		lista.append(paso * float(i))
		lista.append(paso * float(-i))
	return lista


func trazo_desplazado(trazo : PackedVector2Array, desplazamiento : Vector2) -> PackedVector2Array:
	var resultado : PackedVector2Array = PackedVector2Array()
	for punto in trazo:
		resultado.append(punto + desplazamiento)
	return resultado


func esta_cerrada() -> bool:
	var curva : Curve2D = obtener_curva()
	return curva.point_count > 2 and curva.get_point_position(0).is_equal_approx(curva.get_point_position(curva.point_count - 1))


func calcular_cantidad_ovillos(largo_total : float) -> int:
	return roundi(largo_total / separacion_ovillos)


func obtener_puntos() -> PackedVector2Array:
	var base : PackedVector2Array = obtener_curva().tessellate()
	var resultado : PackedVector2Array = PackedVector2Array()
	var desplazamientos : Array[Vector2] = desplazamientos_de_repeticiones()
	var fase : float
	var paso : int
	for indice in desplazamientos.size():
		paso = (indice + 1) / 2
		fase = fase_desplazamiento
		if alternar_direccion_repeticiones and paso % 2 == 1:
			fase = -fase
		resultado.append_array(puntos_de_trazo(global_transform * trazo_desplazado(base, desplazamientos[indice]), fase, efecto_ladrillo and paso % 2 == 1))
	return resultado


func puntos_de_trazo(trazo : PackedVector2Array, fase : float = 0.0, medio_paso : bool = false) -> PackedVector2Array:
	var largo : float = largo_de_polilinea(trazo)
	var cantidad : int = calcular_cantidad_ovillos(largo)
	var resultado : PackedVector2Array = PackedVector2Array()
	var total : int
	if cantidad == 0 or largo <= 0.0:
		return resultado
	if medio_paso:
		fase += largo / cantidad * 0.5
	total = cantidad if esta_cerrada() else cantidad + 1
	for i in total:
		resultado.append(punto_sobre_polilinea(trazo, fposmod(largo * i / cantidad + fase, largo)))
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
	datos.repeticiones = repeticiones
	datos.separacion_repeticiones = separacion_repeticiones
	datos.eje_repeticiones = eje_repeticiones
	datos.offset_repeticiones = offset_repeticiones
	datos.efecto_ladrillo = efecto_ladrillo
	datos.usar_simetria = usar_simetria
	datos.grupo_simetria = get_meta("grupo_simetria", 0)
	datos.rol_simetria = get_meta("rol_simetria", Vector2i.ZERO)
	datos.ejes_simetria.assign(get_meta("ejes_simetria", []))
	datos.velocidad_desplazamiento = velocidad_desplazamiento
	datos.invertir_desplazamiento = invertir_desplazamiento
	datos.alternar_direccion_repeticiones = alternar_direccion_repeticiones
	datos.huecos = PackedInt32Array(huecos)
	return datos


func aplicar_datos(datos : FormaData) -> void:
	position = datos.posicion
	rotation = datos.rotacion
	separacion_ovillos = roundi(datos.separacion_ovillos)
	repeticiones = datos.repeticiones
	separacion_repeticiones = datos.separacion_repeticiones
	eje_repeticiones = datos.eje_repeticiones
	offset_repeticiones = datos.offset_repeticiones
	efecto_ladrillo = datos.efecto_ladrillo
	usar_simetria = datos.usar_simetria
	if datos.grupo_simetria != 0:
		set_meta("grupo_simetria", datos.grupo_simetria)
		set_meta("rol_simetria", datos.rol_simetria)
	if datos.ejes_simetria.is_empty():
		if has_meta("ejes_simetria"):
			remove_meta("ejes_simetria")
	else:
		set_meta("ejes_simetria", datos.ejes_simetria.duplicate())
	velocidad_desplazamiento = datos.velocidad_desplazamiento
	invertir_desplazamiento = datos.invertir_desplazamiento
	alternar_direccion_repeticiones = datos.alternar_direccion_repeticiones
	huecos = PackedInt32Array(datos.huecos) if datos.huecos != null else PackedInt32Array()
	scale = datos.escala
	if datos.curva:
		curve = datos.curva.duplicate()
		curve.changed.connect(actualizar)
	actualizar()
