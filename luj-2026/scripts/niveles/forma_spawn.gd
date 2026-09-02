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
@export var separacion_ovillos : int = 50:
	set(valor):
		separacion_ovillos = maxi(valor, 1)
		actualizar()

@export_group("Simetria")
##crea y mantiene clones espejados de esta forma cuando la simetria del editor esta activa
@export var usar_simetria : bool = false

@export_group("Anillos")
##anillos concentricos hacia adentro de la forma
@export_range(0, 20, 1) var anillos_interiores : int = 0:
	set(valor):
		anillos_interiores = maxi(valor, 0)
		actualizar()
##anillos concentricos hacia afuera de la forma
@export_range(0, 20, 1) var anillos_exteriores : int = 0:
	set(valor):
		anillos_exteriores = maxi(valor, 0)
		actualizar()
##distancia entre un anillo y el siguiente
@export var separacion_anillos : int = 40:
	set(valor):
		separacion_anillos = maxi(valor, 1)
		actualizar()

@export_group("Desplazamiento")
##velocidad en pixeles por segundo con la que los ovillos recorren el contorno, 0 = quietos
@export var velocidad_desplazamiento : float = 0.0
##invierte el sentido del desplazamiento
@export var invertir_desplazamiento : bool = false
##los anillos alternan el sentido del desplazamiento entre si
@export var alternar_direccion_anillos : bool = false

@export_group("Huecos")
##indices de los ovillos de la forma que no aparecen, se editan con la herramienta de seleccion de ovillos
@export var huecos : PackedInt32Array = PackedInt32Array():
	set(valor):
		huecos = valor
		actualizar()

static var previsualizar_movimiento : bool = false

var fase_desplazamiento : float = 0.0


func _ready() -> void:
	set_notify_transform(true)
	actualizar()


func _notification(que : int) -> void:
	if que == NOTIFICATION_TRANSFORM_CHANGED:
		actualizar()


func _process(delta : float) -> void:
	if (Engine.is_editor_hint() and not FormaSpawn.previsualizar_movimiento) or velocidad_desplazamiento == 0.0:
		return
	fase_desplazamiento += velocidad_desplazamiento * (-1.0 if invertir_desplazamiento else 1.0) * delta
	forma_cambiada.emit()


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


func permite_anillos() -> bool:
	return true


func contorno_desplazado(desplazamiento : float) -> PackedVector2Array:
	return obtener_contorno()


func desplazamientos_de_anillos() -> Array[float]:
	var lista : Array[float] = [0.0]
	if not permite_anillos():
		return lista
	for i in range(1, anillos_interiores + 1):
		lista.append(-i * float(separacion_anillos))
	for i in range(1, anillos_exteriores + 1):
		lista.append(i * float(separacion_anillos))
	return lista


func puntos_con_anillos() -> PackedVector2Array:
	var puntos : PackedVector2Array = PackedVector2Array()
	var contorno : PackedVector2Array
	var indice_anillo : int
	var fase : float
	for desplazamiento in desplazamientos_de_anillos():
		contorno = contorno_desplazado(desplazamiento)
		if contorno.is_empty():
			continue
		indice_anillo = roundi(absf(desplazamiento) / separacion_anillos)
		fase = fase_desplazamiento
		if alternar_direccion_anillos and indice_anillo % 2 == 1:
			fase = -fase
		puntos.append_array(puntos_sobre_poligono(a_global(contorno), fase))
	return puntos


func contorno_cerrado() -> bool:
	return true


func esta_sobre_contorno(punto_local : Vector2, tolerancia : float) -> bool:
	var contorno : PackedVector2Array = obtener_contorno()
	var segmentos : int = contorno.size() if contorno_cerrado() else contorno.size() - 1
	var desde : Vector2
	var hasta : Vector2
	for i in segmentos:
		desde = contorno[i]
		hasta = contorno[(i + 1) % contorno.size()]
		if Geometry2D.get_closest_point_to_segment(punto_local, desde, hasta).distance_to(punto_local) <= tolerancia:
			return true
	return false


func usa_rotacion() -> bool:
	return true


func obtener_centro_manijas() -> Vector2:
	return Vector2.ZERO


func obtener_manijas() -> PackedVector2Array:
	var manijas : PackedVector2Array = PackedVector2Array([obtener_centro_manijas()])
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
	var datos : FormaData = FormaData.new()
	datos.posicion = position
	datos.rotacion = rotation
	datos.escala = scale
	datos.separacion_ovillos = separacion_ovillos
	datos.anillos_interiores = anillos_interiores
	datos.anillos_exteriores = anillos_exteriores
	datos.separacion_anillos = separacion_anillos
	datos.velocidad_desplazamiento = velocidad_desplazamiento
	datos.invertir_desplazamiento = invertir_desplazamiento
	datos.alternar_direccion_anillos = alternar_direccion_anillos
	datos.usar_simetria = usar_simetria
	datos.grupo_simetria = get_meta("grupo_simetria", 0)
	datos.rol_simetria = get_meta("rol_simetria", Vector2i.ZERO)
	datos.huecos = PackedInt32Array(huecos)
	return datos


func aplicar_datos(datos : FormaData) -> void:
	position = datos.posicion
	rotation = datos.rotacion
	scale = datos.escala
	separacion_ovillos = roundi(datos.separacion_ovillos)
	anillos_interiores = datos.anillos_interiores
	anillos_exteriores = datos.anillos_exteriores
	separacion_anillos = datos.separacion_anillos
	velocidad_desplazamiento = datos.velocidad_desplazamiento
	invertir_desplazamiento = datos.invertir_desplazamiento
	alternar_direccion_anillos = datos.alternar_direccion_anillos
	usar_simetria = datos.usar_simetria
	if datos.grupo_simetria != 0:
		set_meta("grupo_simetria", datos.grupo_simetria)
		set_meta("rol_simetria", datos.rol_simetria)
	huecos = PackedInt32Array(datos.huecos) if datos.huecos != null else PackedInt32Array()


func a_global(lista : PackedVector2Array) -> PackedVector2Array:
	return global_transform * lista


func puntos_sobre_poligono(vertices : PackedVector2Array, fase : float = 0.0) -> PackedVector2Array:
	var perimetro : float = 0.0
	var cantidad : int
	var separacion_real : float
	var puntos : PackedVector2Array = PackedVector2Array()
	for i in vertices.size():
		perimetro += vertices[i].distance_to(vertices[(i + 1) % vertices.size()])
	cantidad = calcular_cantidad_ovillos(perimetro)
	if cantidad == 0 or perimetro <= 0.0:
		return puntos
	separacion_real = perimetro / cantidad
	for i in cantidad:
		puntos.append(punto_en_poligono(vertices, fposmod(separacion_real * i + fase, perimetro)))
	return puntos


func punto_en_poligono(vertices : PackedVector2Array, distancia : float) -> Vector2:
	var recorrido : float = 0.0
	var desde : Vector2
	var hasta : Vector2
	var largo : float
	for i in vertices.size():
		desde = vertices[i]
		hasta = vertices[(i + 1) % vertices.size()]
		largo = desde.distance_to(hasta)
		if distancia <= recorrido + largo or i == vertices.size() - 1:
			return desde.lerp(hasta, clampf((distancia - recorrido) / largo, 0.0, 1.0) if largo > 0.0 else 0.0)
		recorrido += largo
	return vertices[0] if not vertices.is_empty() else Vector2.ZERO


func calcular_cantidad_ovillos(largo_total : float) -> int:
	return roundi(largo_total / separacion_ovillos)
