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


func _ready() -> void:
	obtener_curva().changed.connect(anclar_origen_de_la_curva)
	anclar_origen_de_la_curva()
	actualizar_seguidor()
	if Engine.is_editor_hint():
		seguidor.child_entered_tree.connect(escuchar_forma)
		var forma := obtener_forma()
		if forma:
			escuchar_forma(forma)


func escuchar_forma(nodo : Node) -> void:
	if nodo.has_signal("forma_cambiada") and not nodo.forma_cambiada.is_connected(seguir_a_la_forma):
		nodo.forma_cambiada.connect(seguir_a_la_forma)


func seguir_a_la_forma() -> void:
	var forma := obtener_forma()
	if not forma or not Engine.is_editor_hint() or forma.position == Vector2.ZERO:
		return
	global_position += forma.global_position - seguidor.global_position
	forma.position = Vector2.ZERO


func anclar_origen_de_la_curva() -> void:
	var curva := obtener_curva()
	if curva.point_count == 0:
		return
	var origen := curva.get_point_position(0)
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
	if Engine.is_editor_hint() or not seguidor or obtener_curva().get_baked_length() <= 0.0:
		return
	seguidor.progress += velocidad * sentido * delta
	if ida_y_vuelta and (seguidor.progress_ratio >= 1.0 or seguidor.progress_ratio <= 0.0):
		sentido *= -1.0


func actualizar_seguidor() -> void:
	if not seguidor or not is_inside_tree():
		return
	seguidor.loop = bucle and not ida_y_vuelta
	seguidor.rotates = rotar_con_el_path
	if obtener_curva().get_baked_length() > 0.0:
		seguidor.progress_ratio = progreso_inicial / 100.0


func obtener_forma() -> Node2D:
	if not seguidor:
		return null
	for hijo in seguidor.get_children():
		if hijo.has_method("obtener_datos"):
			return hijo
	return null


func obtener_datos() -> FormaData:
	var forma := obtener_forma()
	var datos : FormaData = forma.obtener_datos() if forma else FormaData.new()
	datos.recorrido = obtener_curva().duplicate()
	datos.posicion_recorrido = position
	datos.velocidad = velocidad
	datos.bucle = bucle
	datos.ida_y_vuelta = ida_y_vuelta
	datos.rotar_con_el_path = rotar_con_el_path
	datos.progreso_inicial = progreso_inicial
	return datos


func aplicar_datos(datos : FormaData) -> void:
	curve = datos.recorrido.duplicate()
	curve.changed.connect(anclar_origen_de_la_curva)
	position = datos.posicion_recorrido
	velocidad = datos.velocidad
	bucle = datos.bucle
	ida_y_vuelta = datos.ida_y_vuelta
	rotar_con_el_path = datos.rotar_con_el_path
	progreso_inicial = datos.progreso_inicial
