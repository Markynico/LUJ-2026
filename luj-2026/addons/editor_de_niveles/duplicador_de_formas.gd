@tool
class_name DuplicadorDeFormas
extends Node

signal duplicar_pedido(forma : Node2D)

var control_viewport : Control


func _init(control_viewport_2d : Control) -> void:
	control_viewport = control_viewport_2d


func _input(evento : InputEvent) -> void:
	var cargador : CargadorDeNivel
	var forma : Node2D
	if not evento is InputEventKey or not evento.pressed or evento.echo or evento.keycode != KEY_D or not evento.is_command_or_control_pressed():
		return
	if not control_viewport or not control_viewport.is_visible_in_tree():
		return
	cargador = EditorInterface.get_edited_scene_root() as CargadorDeNivel
	if not cargador:
		return
	forma = buscar_forma_seleccionada(cargador)
	if not forma:
		return
	get_viewport().set_input_as_handled()
	duplicar_pedido.emit(forma)


func buscar_forma_seleccionada(cargador : CargadorDeNivel) -> Node2D:
	var formas : Array[Node2D] = cargador.obtener_formas()
	var actual : Node
	for nodo in EditorInterface.get_selection().get_selected_nodes():
		actual = nodo
		while actual and actual != cargador:
			if formas.has(actual):
				return actual
			actual = actual.get_parent()
	return null
