@tool
class_name ManijasForma
extends RefCounted

var radio_manija : float = 6.0
var color_manija : Color = Color(1.0, 0.55, 0.1)
var color_manija_activa : Color = Color(1.0, 1.0, 1.0)
var forma : FormaSpawn
var deshacer_rehacer : EditorUndoRedoManager
var manija_activa : int = -1
var estado_inicial : Dictionary
var desplazamiento_agarre : Vector2


func _init(manejador_deshacer : EditorUndoRedoManager) -> void:
	deshacer_rehacer = manejador_deshacer


func transformacion_viewport() -> Transform2D:
	return EditorInterface.get_editor_viewport_2d().global_canvas_transform


func dibujar(superficie : Control) -> void:
	var transformacion : Transform2D
	var manijas : PackedVector2Array
	var color : Color
	if not es_valida():
		return
	transformacion = transformacion_viewport() * forma.global_transform
	manijas = forma.obtener_manijas()
	for i in manijas.size():
		color = color_manija_activa if i == manija_activa else color_manija
		superficie.draw_circle(transformacion * manijas[i], radio_manija, color)


func procesar_input(evento : InputEvent) -> bool:
	if not es_valida():
		return false
	if evento is InputEventMouseButton and evento.button_index == MOUSE_BUTTON_LEFT:
		if evento.pressed:
			return empezar_arrastre(evento.position)
		return terminar_arrastre()
	if evento is InputEventMouseMotion and manija_activa >= 0:
		arrastrar(evento.position, evento.shift_pressed, evento.ctrl_pressed)
		return true
	return false


func empezar_arrastre(posicion_pantalla : Vector2) -> bool:
	var indice : int = buscar_manija_en(posicion_pantalla)
	if indice < 0:
		return false
	manija_activa = indice
	desplazamiento_agarre = Vector2.ZERO
	estado_inicial = capturar_estado()
	forma.empezar_arrastre_manija(indice)
	return true


func empezar_arrastre_desde_contorno(forma_agarrada : FormaSpawn, posicion_pantalla : Vector2) -> void:
	forma = forma_agarrada
	manija_activa = FormaSpawn.ManijaBase.CENTRO
	desplazamiento_agarre = a_local(posicion_pantalla) - forma.obtener_centro_manijas()
	estado_inicial = capturar_estado()


func hay_manija_en(posicion_pantalla : Vector2) -> bool:
	return es_valida() and buscar_manija_en(posicion_pantalla) >= 0


func buscar_manija_en(posicion_pantalla : Vector2) -> int:
	var transformacion : Transform2D = transformacion_viewport() * forma.global_transform
	var manijas : PackedVector2Array = forma.obtener_manijas()
	for i in manijas.size():
		if (transformacion * manijas[i]).distance_to(posicion_pantalla) <= radio_manija * 1.5:
			return i
	return -1


func arrastrar(posicion_pantalla : Vector2, con_shift : bool, con_control : bool) -> void:
	var posicion_local : Vector2 = a_local(posicion_pantalla) - desplazamiento_agarre
	forma.mover_manija(manija_activa, posicion_local, con_shift, con_control)


func a_local(posicion_pantalla : Vector2) -> Vector2:
	return forma.get_global_transform().affine_inverse() * (transformacion_viewport().affine_inverse() * posicion_pantalla)


func terminar_arrastre() -> bool:
	var estado_final : Dictionary
	if manija_activa < 0:
		return false
	estado_final = capturar_estado()
	deshacer_rehacer.create_action("Mover manija de forma")
	for propiedad in estado_final:
		deshacer_rehacer.add_do_property(forma, propiedad, estado_final[propiedad])
		deshacer_rehacer.add_undo_property(forma, propiedad, estado_inicial[propiedad])
	deshacer_rehacer.commit_action()
	manija_activa = -1
	return true


func capturar_estado() -> Dictionary:
	var estado : Dictionary = {}
	for propiedad in forma.get_property_list():
		if propiedad.usage & PROPERTY_USAGE_SCRIPT_VARIABLE and propiedad.usage & PROPERTY_USAGE_STORAGE:
			estado[propiedad.name] = forma.get(propiedad.name)
	estado["position"] = forma.position
	estado["rotation"] = forma.rotation
	estado["scale"] = forma.scale
	return estado


func es_valida() -> bool:
	return is_instance_valid(forma) and forma.is_inside_tree()
