@tool
class_name FormaPoligono
extends Polygon2D

signal forma_cambiada

##distancia entre un ovillo y el siguiente dentro de cada fila de la grilla
@export var separacion_ovillos : int = 50:
	set(valor):
		separacion_ovillos = maxi(valor, 1)
		actualizar()

@export_group("Simetria")
##crea y mantiene clones espejados de este poligono cuando la simetria del editor esta activa
@export var usar_simetria : bool = false

@export_group("Grilla")
##angulo en grados de las filas de la grilla
@export_range(-180.0, 180.0, 0.5) var angulo_grilla : float = 0.0:
	set(valor):
		angulo_grilla = valor
		actualizar()
##distancia entre una fila y la siguiente
@export var separacion_filas : int = 50:
	set(valor):
		separacion_filas = maxi(valor, 1)
		actualizar()
##corrimiento de la grilla, x a lo largo de las filas e y entre filas
@export var offset_grilla : Vector2 = Vector2.ZERO:
	set(valor):
		offset_grilla = valor
		actualizar()
##las filas alternadas corren sus ovillos medio paso, como ladrillos
@export var efecto_ladrillo : bool = false:
	set(valor):
		efecto_ladrillo = valor
		actualizar()

@export_group("Desplazamiento")
##velocidad en pixeles por segundo con la que los ovillos recorren las filas, 0 = quietos
@export var velocidad_desplazamiento : float = 0.0
##invierte el sentido del desplazamiento
@export var invertir_desplazamiento : bool = false
##las filas alternan el sentido del desplazamiento entre si
@export var alternar_direccion_filas : bool = false

@export_group("Huecos")
##indices de los ovillos del poligono que no aparecen, se editan con la herramienta de seleccion de ovillos
@export var huecos : PackedInt32Array = PackedInt32Array():
	set(valor):
		huecos = valor
		actualizar()

var fase_desplazamiento : float = 0.0
var poligono_anterior : PackedVector2Array = PackedVector2Array()


func _ready() -> void:
	set_notify_transform(true)
	if not Engine.is_editor_hint():
		color = Color(0.0, 0.0, 0.0, 0.0)
	poligono_anterior = polygon.duplicate()
	actualizar()


func _notification(que : int) -> void:
	if que == NOTIFICATION_TRANSFORM_CHANGED:
		actualizar()


func _process(delta : float) -> void:
	if Engine.is_editor_hint() and polygon != poligono_anterior:
		poligono_anterior = polygon.duplicate()
		actualizar()
	if (Engine.is_editor_hint() and not FormaSpawn.previsualizar_movimiento) or velocidad_desplazamiento == 0.0:
		return
	fase_desplazamiento += velocidad_desplazamiento * (-1.0 if invertir_desplazamiento else 1.0) * delta
	forma_cambiada.emit()


func actualizar() -> void:
	queue_redraw()
	forma_cambiada.emit()


func obtener_contorno() -> PackedVector2Array:
	return polygon


func direccion_filas() -> Vector2:
	return Vector2.from_angle(global_rotation + deg_to_rad(angulo_grilla))


func obtener_puntos() -> PackedVector2Array:
	var resultado : PackedVector2Array = PackedVector2Array()
	var vertices : PackedVector2Array = global_transform * polygon
	var u : Vector2 = direccion_filas()
	var v : Vector2 = u.orthogonal()
	var minimo_v : float = INF
	var maximo_v : float = -INF
	var fila_desde : int
	var fila_hasta : int
	var alto : float
	var cortes : PackedFloat32Array
	var desfase : float
	var fase : float
	if vertices.size() < 3:
		return resultado
	for vertice in vertices:
		minimo_v = minf(minimo_v, vertice.dot(v))
		maximo_v = maxf(maximo_v, vertice.dot(v))
	fila_desde = ceili((minimo_v - offset_grilla.y) / separacion_filas)
	fila_hasta = floori((maximo_v - offset_grilla.y) / separacion_filas)
	for fila in range(fila_desde, fila_hasta + 1):
		alto = fila * separacion_filas + offset_grilla.y
		cortes = cortes_de_fila(vertices, u, v, alto)
		if cortes.size() < 2:
			continue
		desfase = offset_grilla.x
		if efecto_ladrillo and posmod(fila, 2) == 1:
			desfase += separacion_ovillos * 0.5
		fase = fase_desplazamiento
		if alternar_direccion_filas and posmod(fila, 2) == 1:
			fase = -fase
		resultado.append_array(puntos_de_fila(cortes, desfase, fase, u, v, alto))
	return resultado


func cortes_de_fila(vertices : PackedVector2Array, u : Vector2, v : Vector2, alto : float) -> PackedFloat32Array:
	var cortes : PackedFloat32Array = PackedFloat32Array()
	var desde : Vector2
	var hasta : Vector2
	var desde_v : float
	var hasta_v : float
	var avance : float
	for i in vertices.size():
		desde = vertices[i]
		hasta = vertices[(i + 1) % vertices.size()]
		desde_v = desde.dot(v)
		hasta_v = hasta.dot(v)
		if (desde_v <= alto) == (hasta_v <= alto):
			continue
		avance = (alto - desde_v) / (hasta_v - desde_v)
		cortes.append(desde.dot(u) + avance * (hasta.dot(u) - desde.dot(u)))
	cortes.sort()
	if cortes.size() % 2 == 1:
		cortes.remove_at(cortes.size() - 1)
	return cortes


func puntos_de_fila(cortes : PackedFloat32Array, desfase : float, fase : float, u : Vector2, v : Vector2, alto : float) -> PackedVector2Array:
	var resultado : PackedVector2Array = PackedVector2Array()
	var largo_interior : float = 0.0
	var distancias : PackedFloat32Array = PackedFloat32Array()
	var posicion_u : float
	var distancia : float
	for i in range(0, cortes.size(), 2):
		largo_interior += cortes[i + 1] - cortes[i]
	if largo_interior <= 0.0:
		return resultado
	for j in range(ceili((cortes[0] - desfase) / separacion_ovillos), floori((cortes[cortes.size() - 1] - desfase) / separacion_ovillos) + 1):
		posicion_u = j * separacion_ovillos + desfase
		distancia = distancia_interior(cortes, posicion_u)
		if distancia >= 0.0:
			distancias.append(distancia)
	for recorrida in distancias:
		posicion_u = posicion_interior(cortes, fposmod(recorrida + fase, largo_interior))
		resultado.append(u * posicion_u + v * alto)
	return resultado


func distancia_interior(cortes : PackedFloat32Array, posicion_u : float) -> float:
	var acumulado : float = 0.0
	for i in range(0, cortes.size(), 2):
		if posicion_u >= cortes[i] and posicion_u <= cortes[i + 1]:
			return acumulado + posicion_u - cortes[i]
		acumulado += cortes[i + 1] - cortes[i]
	return -1.0


func posicion_interior(cortes : PackedFloat32Array, distancia : float) -> float:
	var acumulado : float = 0.0
	var largo_tramo : float
	for i in range(0, cortes.size(), 2):
		largo_tramo = cortes[i + 1] - cortes[i]
		if distancia <= acumulado + largo_tramo:
			return cortes[i] + distancia - acumulado
		acumulado += largo_tramo
	return cortes[cortes.size() - 1]


func obtener_datos() -> FormaData:
	var datos : FormaData = FormaData.new()
	datos.tipo = "poligono"
	datos.posicion = position
	datos.rotacion = rotation
	datos.escala = scale
	datos.separacion_ovillos = separacion_ovillos
	datos.poligono = polygon.duplicate()
	datos.angulo_grilla = angulo_grilla
	datos.separacion_filas = separacion_filas
	datos.offset_grilla = offset_grilla
	datos.efecto_ladrillo = efecto_ladrillo
	datos.velocidad_desplazamiento = velocidad_desplazamiento
	datos.invertir_desplazamiento = invertir_desplazamiento
	datos.alternar_direccion_filas = alternar_direccion_filas
	datos.usar_simetria = usar_simetria
	datos.grupo_simetria = get_meta("grupo_simetria", 0)
	datos.rol_simetria = get_meta("rol_simetria", Vector2i.ZERO)
	datos.ejes_simetria.assign(get_meta("ejes_simetria", []))
	datos.huecos = PackedInt32Array(huecos)
	return datos


func aplicar_datos(datos : FormaData) -> void:
	position = datos.posicion
	rotation = datos.rotacion
	scale = datos.escala
	separacion_ovillos = roundi(datos.separacion_ovillos)
	polygon = PackedVector2Array(datos.poligono) if datos.poligono != null else PackedVector2Array()
	poligono_anterior = polygon.duplicate()
	angulo_grilla = datos.angulo_grilla
	separacion_filas = datos.separacion_filas
	offset_grilla = datos.offset_grilla
	efecto_ladrillo = datos.efecto_ladrillo
	velocidad_desplazamiento = datos.velocidad_desplazamiento
	invertir_desplazamiento = datos.invertir_desplazamiento
	alternar_direccion_filas = datos.alternar_direccion_filas
	usar_simetria = datos.usar_simetria
	if datos.grupo_simetria != 0:
		set_meta("grupo_simetria", datos.grupo_simetria)
		set_meta("rol_simetria", datos.rol_simetria)
	if datos.ejes_simetria.is_empty():
		if has_meta("ejes_simetria"):
			remove_meta("ejes_simetria")
	else:
		set_meta("ejes_simetria", datos.ejes_simetria.duplicate())
	huecos = PackedInt32Array(datos.huecos) if datos.huecos != null else PackedInt32Array()
	actualizar()
