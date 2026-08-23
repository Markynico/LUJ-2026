@tool
class_name ManijasForma
extends RefCounted

var radio_manija : float = 6.0
var color_manija : Color = Color(1.0, 0.55, 0.1)
var color_manija_activa : Color = Color(1.0, 1.0, 1.0)
var paso_snap_rotacion : float = deg_to_rad(45.0)
var forma : FormaSpawn
var deshacer_rehacer : EditorUndoRedoManager
var manija_activa : int = -1
var estado_inicial : Dictionary


func _init(manejador_deshacer : EditorUndoRedoManager) -> void:
	deshacer_rehacer = manejador_deshacer


func transformacion_viewport() -> Transform2D:
	return EditorInterface.get_editor_viewport_2d().global_canvas_transform


func dibujar(superficie : Control) -> void:
	if not es_valida():
		return
	var transformacion := transformacion_viewport() * forma.global_transform
	var manijas := forma.obtener_manijas()
	for i in manijas.size():
		var color := color_manija_activa if i == manija_activa else color_manija
		superficie.draw_circle(transformacion * manijas[i], radio_manija, color)


func procesar_input(evento : InputEvent) -> bool:
	if not es_valida():
		return false
	if evento is InputEventMouseButton and evento.button_index == MOUSE_BUTTON_LEFT:
		if evento.pressed:
			return empezar_arrastre(evento.position)
		return terminar_arrastre()
	if evento is InputEventMouseMotion and manija_activa >= 0:
		arrastrar(evento.position, evento.shift_pressed)
		return true
	return false


func empezar_arrastre(posicion_pantalla : Vector2) -> bool:
	var transformacion := transformacion_viewport() * forma.global_transform
	var manijas := forma.obtener_manijas()
	for i in manijas.size():
		if (transformacion * manijas[i]).distance_to(posicion_pantalla) <= radio_manija * 1.5:
			manija_activa = i
			estado_inicial = capturar_estado()
			return true
	return false


func arrastrar(posicion_pantalla : Vector2, con_snap : bool) -> void:
	var posicion_local := forma.get_global_transform().affine_inverse() * (transformacion_viewport().affine_inverse() * posicion_pantalla)
	forma.mover_manija(manija_activa, posicion_local)
	if con_snap and manija_activa == FormaSpawn.ManijaBase.ROTACION:
		forma.rotation = snappedf(forma.rotation, paso_snap_rotacion)


func terminar_arrastre() -> bool:
	if manija_activa < 0:
		return false
	var estado_final := capturar_estado()
	deshacer_rehacer.create_action("Mover manija de forma")
	for propiedad in estado_final:
		deshacer_rehacer.add_do_property(forma, propiedad, estado_final[propiedad])
		deshacer_rehacer.add_undo_property(forma, propiedad, estado_inicial[propiedad])
	deshacer_rehacer.commit_action()
	manija_activa = -1
	return true


func capturar_estado() -> Dictionary:
	var estado := {}
	for propiedad in forma.get_property_list():
		if propiedad.usage & PROPERTY_USAGE_SCRIPT_VARIABLE and propiedad.usage & PROPERTY_USAGE_STORAGE:
			estado[propiedad.name] = forma.get(propiedad.name)
	estado["position"] = forma.position
	estado["rotation"] = forma.rotation
	return estado


func es_valida() -> bool:
	return is_instance_valid(forma) and forma.is_inside_tree()
