@tool
class_name SelectorDeOvillos
extends Node

const COLOR_SELECCION := Color(1.0, 0.2, 0.2, 0.85)
const COLOR_RECUADRO := Color(1.0, 0.3, 0.3, 0.2)
const COLOR_BORDE_RECUADRO := Color(1.0, 0.3, 0.3, 0.9)
const UMBRAL_ARRASTRE := 4.0
const MARGEN_CLICK := 4.0

var plugin : EditorPlugin
var control_viewport : Control
var deshacer_rehacer : EditorUndoRedoManager
var activo : bool = false
var seleccion : Array[Dictionary] = []
var arrastrando : bool = false
var mantener_seleccion : bool = false
var inicio_pantalla : Vector2
var actual_pantalla : Vector2


func _init(plugin_editor : EditorPlugin, control_viewport_2d : Control, manejador_deshacer : EditorUndoRedoManager) -> void:
	plugin = plugin_editor
	control_viewport = control_viewport_2d
	deshacer_rehacer = manejador_deshacer


func activar(nuevo_estado : bool) -> void:
	activo = nuevo_estado
	arrastrando = false
	seleccion.clear()
	plugin.update_overlays()


func _input(evento : InputEvent) -> void:
	var posicion : Vector2
	if not activo:
		return
	if evento is InputEventKey and evento.pressed and not evento.echo and evento.keycode == KEY_DELETE and not seleccion.is_empty():
		eliminar_seleccion()
		get_viewport().set_input_as_handled()
		return
	if not control_viewport or not control_viewport.is_visible_in_tree():
		return
	posicion = control_viewport.get_local_mouse_position()
	if evento is InputEventMouseButton and evento.button_index == MOUSE_BUTTON_LEFT:
		if evento.pressed and Rect2(Vector2.ZERO, control_viewport.size).has_point(posicion):
			arrastrando = true
			mantener_seleccion = evento.shift_pressed
			inicio_pantalla = posicion
			actual_pantalla = posicion
			get_viewport().set_input_as_handled()
		elif not evento.pressed and arrastrando:
			arrastrando = false
			actual_pantalla = posicion
			terminar_arrastre()
			get_viewport().set_input_as_handled()
	elif evento is InputEventMouseMotion and arrastrando:
		actual_pantalla = posicion
		plugin.update_overlays()
		get_viewport().set_input_as_handled()


func terminar_arrastre() -> void:
	var recuadro : Rect2
	if not mantener_seleccion:
		seleccion.clear()
	if inicio_pantalla.distance_to(actual_pantalla) < UMBRAL_ARRASTRE:
		alternar_en(actual_pantalla)
	else:
		recuadro = Rect2(inicio_pantalla, actual_pantalla - inicio_pantalla).abs()
		for entrada in entradas_visibles():
			if recuadro.has_point(a_pantalla(entrada.spawn.global_position)) and not contiene(entrada):
				seleccion.append(entrada)
	plugin.update_overlays()


func alternar_en(posicion_pantalla : Vector2) -> void:
	var escala : float = transformacion_viewport().get_scale().x
	var mejor : Dictionary = {}
	var mejor_distancia : float = INF
	var distancia : float
	for entrada in entradas_visibles():
		distancia = a_pantalla(entrada.spawn.global_position).distance_to(posicion_pantalla)
		if distancia <= entrada.spawn.obtener_radio_colision() * escala + MARGEN_CLICK and distancia < mejor_distancia:
			mejor = entrada
			mejor_distancia = distancia
	if mejor.is_empty():
		return
	for i in seleccion.size():
		if seleccion[i].spawn == mejor.spawn:
			seleccion.remove_at(i)
			return
	seleccion.append(mejor)


func contiene(entrada : Dictionary) -> bool:
	for existente in seleccion:
		if existente.spawn == entrada.spawn:
			return true
	return false


func entradas_visibles() -> Array[Dictionary]:
	var cargador : CargadorDeNivel = EditorInterface.get_edited_scene_root() as CargadorDeNivel
	var entradas : Array[Dictionary] = []
	var generador : Node
	var forma : Node2D
	if not cargador:
		return entradas
	for spawn in cargador.find_children("*", "SpawnOvillo", true, false):
		if spawn.anulado:
			continue
		generador = spawn.get_parent()
		if not generador is GeneradorDeOvillos or not generador.forma:
			continue
		forma = forma_editable(cargador, generador.forma)
		if not forma:
			continue
		entradas.append({"spawn": spawn, "forma": forma, "indice": spawn.get_index()})
	return entradas


func forma_editable(cargador : CargadorDeNivel, forma : Node2D) -> Node2D:
	var recorrido : MovimientoPorPath = cargador.obtener_recorrido(forma)
	if recorrido:
		return recorrido.obtener_forma()
	if forma.get_parent() == cargador:
		return forma
	return null


func eliminar_seleccion() -> void:
	var por_forma : Dictionary = {}
	var nuevos : PackedInt32Array
	if seleccion.is_empty():
		return
	for entrada in seleccion:
		if not is_instance_valid(entrada.forma):
			continue
		if not por_forma.has(entrada.forma):
			por_forma[entrada.forma] = PackedInt32Array(entrada.forma.huecos)
		if not por_forma[entrada.forma].has(entrada.indice):
			por_forma[entrada.forma].append(entrada.indice)
	deshacer_rehacer.create_action("Eliminar ovillos")
	for forma in por_forma:
		nuevos = por_forma[forma]
		nuevos.sort()
		deshacer_rehacer.add_do_property(forma, "huecos", nuevos)
		deshacer_rehacer.add_undo_property(forma, "huecos", PackedInt32Array(forma.huecos))
	deshacer_rehacer.commit_action()
	seleccion.clear()
	plugin.update_overlays()


func restaurar(forma : Node2D) -> void:
	if not forma or not "huecos" in forma or forma.huecos.is_empty():
		return
	deshacer_rehacer.create_action("Restaurar ovillos")
	deshacer_rehacer.add_do_property(forma, "huecos", PackedInt32Array())
	deshacer_rehacer.add_undo_property(forma, "huecos", PackedInt32Array(forma.huecos))
	deshacer_rehacer.commit_action()


func dibujar(superficie : Control) -> void:
	var escala : float
	var recuadro : Rect2
	if not activo:
		return
	escala = transformacion_viewport().get_scale().x
	for entrada in seleccion:
		if is_instance_valid(entrada.spawn):
			superficie.draw_circle(a_pantalla(entrada.spawn.global_position), entrada.spawn.obtener_radio_colision() * escala, COLOR_SELECCION)
	if arrastrando and inicio_pantalla.distance_to(actual_pantalla) >= UMBRAL_ARRASTRE:
		recuadro = Rect2(inicio_pantalla, actual_pantalla - inicio_pantalla).abs()
		superficie.draw_rect(recuadro, COLOR_RECUADRO, true)
		superficie.draw_rect(recuadro, COLOR_BORDE_RECUADRO, false, 1.0)


func transformacion_viewport() -> Transform2D:
	return EditorInterface.get_editor_viewport_2d().global_canvas_transform


func a_pantalla(posicion_global : Vector2) -> Vector2:
	return transformacion_viewport() * posicion_global
