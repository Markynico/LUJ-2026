@tool
class_name SelectorDeFormas
extends Node

var manijas : ManijasForma
var plugin : EditorPlugin
var control_viewport : Control


func _init(manejador_manijas : ManijasForma, plugin_editor : EditorPlugin, control_viewport_2d : Control) -> void:
	manijas = manejador_manijas
	plugin = plugin_editor
	control_viewport = control_viewport_2d


func _input(evento : InputEvent) -> void:
	if es_soltar_izquierdo(evento) and manijas.terminar_arrastre():
		plugin.update_overlays()
		return
	if not es_click_izquierdo(evento) or not control_viewport or not control_viewport.is_visible_in_tree():
		return
	var posicion := control_viewport.get_local_mouse_position()
	if not Rect2(Vector2.ZERO, control_viewport.size).has_point(posicion):
		return
	if manijas.hay_manija_en(posicion):
		return
	if seleccionar_forma_en(posicion):
		get_viewport().set_input_as_handled()


func es_click_izquierdo(evento : InputEvent) -> bool:
	return evento is InputEventMouseButton and evento.button_index == MOUSE_BUTTON_LEFT and evento.pressed


func es_soltar_izquierdo(evento : InputEvent) -> bool:
	return evento is InputEventMouseButton and evento.button_index == MOUSE_BUTTON_LEFT and not evento.pressed


func seleccionar(nodo : Node) -> void:
	var seleccion := EditorInterface.get_selection()
	seleccion.clear()
	seleccion.add_node(nodo)


func seleccionar_forma_en(posicion_pantalla : Vector2) -> bool:
	var cargador := EditorInterface.get_edited_scene_root() as CargadorDeNivel
	if not cargador:
		return false
	var transformacion_viewport := EditorInterface.get_editor_viewport_2d().global_canvas_transform
	var tolerancia := manijas.radio_manija / transformacion_viewport.get_scale().x
	for forma in cargador.obtener_formas():
		if not forma is FormaSpawn:
			continue
		var punto_local := forma.global_transform.affine_inverse() * (transformacion_viewport.affine_inverse() * posicion_pantalla)
		if forma.esta_sobre_contorno(punto_local, tolerancia):
			seleccionar(forma)
			manijas.empezar_arrastre_desde_contorno(forma, posicion_pantalla)
			return true
	return false
