@tool
class_name MovimientoPorPath
extends Path2D

##PathFollow2D hijo que lleva a la forma por el recorrido
@export var seguidor : PathFollow2D
##velocidad de avance en pixeles por segundo, negativa para ir al reves
@export var velocidad : float = 100.0
##al llegar al final vuelve a empezar desde el principio
@export var bucle : bool = false:
	set(valor):
		bucle = valor
		actualizar_seguidor()
##al llegar a un extremo invierte el sentido
@export var ida_y_vuelta : bool = true
##arranca recorriendo el path al reves
@export var invertido : bool = false:
	set(valor):
		invertido = valor
		sentido = -1.0 if invertido else 1.0
##la forma arranca desde el otro extremo del recorrido
@export var arranque_invertido : bool = false:
	set(valor):
		arranque_invertido = valor
		actualizar_seguidor()
##copias extra de la forma repartidas a lo largo del recorrido
@export_range(0, 20, 1) var copias_recorrido : int = 0:
	set(valor):
		copias_recorrido = maxi(valor, 0)
		regenerar_copias()
##la forma gira siguiendo la direccion del recorrido
@export var rotar_con_el_path : bool = false:
	set(valor):
		rotar_con_el_path = valor
		actualizar_seguidor()
##porcentaje del recorrido donde arranca la forma, 0 es el inicio y 100 el final
@export_range(0.0, 100.0, 1.0) var progreso_inicial : float = 0.0:
	set(valor):
		progreso_inicial = valor
		actualizar_seguidor()

var sentido : float = 1.0
var seguidores_extra : Array[PathFollow2D] = []
var sentidos_extra : Array[float] = []
var actualizacion_copias_pendiente : bool = false


func _ready() -> void:
	var forma : Node2D
	obtener_curva().changed.connect(anclar_origen_de_la_curva)
	anclar_origen_de_la_curva()
	actualizar_seguidor()
	regenerar_copias()
	forma = obtener_forma()
	if forma:
		escuchar_forma(forma)
	if Engine.is_editor_hint():
		seguidor.child_entered_tree.connect(escuchar_forma)


func escuchar_forma(nodo : Node) -> void:
	if not nodo.has_signal("forma_cambiada"):
		return
	if not nodo.forma_cambiada.is_connected(seguir_a_la_forma):
		nodo.forma_cambiada.connect(seguir_a_la_forma)
	if not nodo.forma_cambiada.is_connected(pedir_actualizar_copias):
		nodo.forma_cambiada.connect(pedir_actualizar_copias)


func seguir_a_la_forma() -> void:
	var forma : Node2D = obtener_forma()
	if not forma or not Engine.is_editor_hint() or forma.position == Vector2.ZERO:
		return
	global_position += forma.global_position - seguidor.global_position
	forma.position = Vector2.ZERO


func anclar_origen_de_la_curva() -> void:
	var curva : Curve2D = obtener_curva()
	var origen : Vector2
	if curva.point_count == 0:
		return
	origen = curva.get_point_position(0)
	if origen == Vector2.ZERO:
		return
	for i in curva.point_count:
		curva.set_point_position(i, curva.get_point_position(i) - origen)
	position += origen.rotated(rotation) * scale


func obtener_curva() -> Curve2D:
	if not curve:
		curve = Curve2D.new()
	if curve.point_count == 0:
		curve.add_point(Vector2.ZERO)
	return curve


func _physics_process(delta : float) -> void:
	if (Engine.is_editor_hint() and not FormaSpawn.previsualizar_movimiento) or not seguidor or obtener_curva().get_baked_length() <= 0.0:
		return
	seguidor.progress += velocidad * sentido * delta
	if ida_y_vuelta and (seguidor.progress_ratio >= 1.0 or seguidor.progress_ratio <= 0.0):
		sentido *= -1.0
	for i in seguidores_extra.size():
		seguidores_extra[i].progress += velocidad * sentidos_extra[i] * delta
		if ida_y_vuelta and (seguidores_extra[i].progress_ratio >= 1.0 or seguidores_extra[i].progress_ratio <= 0.0):
			sentidos_extra[i] *= -1.0


func actualizar_seguidor() -> void:
	if not seguidor or not is_inside_tree():
		return
	seguidor.loop = bucle and not ida_y_vuelta
	seguidor.rotates = rotar_con_el_path
	if obtener_curva().get_baked_length() > 0.0:
		seguidor.progress_ratio = 1.0 - progreso_inicial / 100.0 if arranque_invertido else progreso_inicial / 100.0
	acomodar_copias()


func regenerar_copias() -> void:
	var forma : Node2D = obtener_forma()
	var padre : Node = get_parent()
	var datos : FormaData
	var seguidor_extra : PathFollow2D
	var copia : Node2D
	for viejo in seguidores_extra:
		if is_instance_valid(viejo):
			viejo.queue_free()
	seguidores_extra.clear()
	sentidos_extra.clear()
	if not forma or not is_inside_tree() or copias_recorrido == 0 or not padre is CargadorDeNivel:
		return
	datos = forma.obtener_datos()
	for i in copias_recorrido:
		seguidor_extra = PathFollow2D.new()
		seguidor_extra.loop = bucle and not ida_y_vuelta
		seguidor_extra.rotates = rotar_con_el_path
		add_child(seguidor_extra)
		copia = padre.escenas_formas[datos.tipo].instantiate()
		seguidor_extra.add_child(copia)
		copia.aplicar_datos(datos)
		copia.position = Vector2.ZERO
		seguidores_extra.append(seguidor_extra)
		sentidos_extra.append(sentido)
	acomodar_copias()


func pedir_actualizar_copias() -> void:
	if actualizacion_copias_pendiente or seguidores_extra.is_empty():
		return
	if not Engine.is_editor_hint() or FormaSpawn.previsualizar_movimiento:
		return
	actualizacion_copias_pendiente = true
	actualizar_copias.call_deferred()


func actualizar_copias() -> void:
	var forma : Node2D = obtener_forma()
	var datos : FormaData
	var copia : Node2D
	actualizacion_copias_pendiente = false
	if not forma:
		return
	datos = forma.obtener_datos()
	for seguidor_extra in seguidores_extra:
		if not is_instance_valid(seguidor_extra) or seguidor_extra.get_child_count() == 0:
			continue
		copia = seguidor_extra.get_child(0)
		copia.aplicar_datos(datos)
		copia.position = Vector2.ZERO


func acomodar_copias() -> void:
	if seguidores_extra.is_empty() or obtener_curva().get_baked_length() <= 0.0:
		return
	for i in seguidores_extra.size():
		if not is_instance_valid(seguidores_extra[i]):
			continue
		seguidores_extra[i].progress_ratio = fposmod(seguidor.progress_ratio + float(i + 1) / (copias_recorrido + 1), 1.0)


func obtener_forma() -> Node2D:
	if not seguidor:
		return null
	for hijo in seguidor.get_children():
		if hijo.has_method("obtener_datos"):
			return hijo
	return null


func obtener_datos() -> FormaData:
	var forma : Node2D = obtener_forma()
	var datos : FormaData = forma.obtener_datos() if forma else FormaData.new()
	datos.recorrido = obtener_curva().duplicate()
	datos.posicion_recorrido = position
	datos.rotacion_recorrido = rotation
	datos.escala_recorrido = scale
	datos.velocidad = velocidad
	datos.bucle = bucle
	datos.ida_y_vuelta = ida_y_vuelta
	datos.rotar_con_el_path = rotar_con_el_path
	datos.progreso_inicial = progreso_inicial
	datos.recorrido_invertido = invertido
	datos.arranque_invertido = arranque_invertido
	datos.copias_recorrido = copias_recorrido
	return datos


func aplicar_datos(datos : FormaData) -> void:
	curve = datos.recorrido.duplicate()
	curve.changed.connect(anclar_origen_de_la_curva)
	position = datos.posicion_recorrido
	rotation = datos.rotacion_recorrido
	scale = datos.escala_recorrido
	velocidad = datos.velocidad
	bucle = datos.bucle
	ida_y_vuelta = datos.ida_y_vuelta
	rotar_con_el_path = datos.rotar_con_el_path
	progreso_inicial = datos.progreso_inicial
	invertido = datos.recorrido_invertido
	arranque_invertido = datos.arranque_invertido
	copias_recorrido = datos.copias_recorrido
