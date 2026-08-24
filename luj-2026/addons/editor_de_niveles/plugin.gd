@tool
extends EditorPlugin

const ESCENA_DOCK := preload("uid://bdockeditortsc1")
const CARPETA_NIVELES := "res://niveles/"

var dock : DockEditorDeNiveles
var manijas : ManijasForma
var dialogo_archivo : EditorFileDialog
var selector : SelectorDeFormas


func _enter_tree() -> void:
	dock = ESCENA_DOCK.instantiate()
	dock.crear_forma.connect(crear_forma)
	dock.nuevo_nivel.connect(nuevo_nivel)
	dock.guardar_nivel.connect(guardar_nivel)
	dock.cargar_nivel.connect(abrir_dialogo_cargar)
	dock.agregar_recorrido.connect(agregar_recorrido)
	dock.quitar_recorrido.connect(quitar_recorrido)
	add_control_to_dock(DOCK_SLOT_LEFT_UL, dock)
	manijas = ManijasForma.new(get_undo_redo())
	selector = SelectorDeFormas.new(manijas, self, buscar_control_viewport())
	EditorInterface.get_base_control().add_child(selector)
	dialogo_archivo = EditorFileDialog.new()
	dialogo_archivo.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	dialogo_archivo.access = EditorFileDialog.ACCESS_RESOURCES
	dialogo_archivo.add_filter("*.tres", "Nivel")
	dialogo_archivo.current_dir = CARPETA_NIVELES
	dialogo_archivo.file_selected.connect(cargar_nivel)
	EditorInterface.get_base_control().add_child(dialogo_archivo)


func _exit_tree() -> void:
	remove_control_from_docks(dock)
	dock.queue_free()
	dialogo_archivo.queue_free()
	selector.queue_free()


func _handles(objeto : Object) -> bool:
	return objeto is FormaSpawn


func _edit(objeto : Object) -> void:
	manijas.forma = objeto as FormaSpawn
	update_overlays()


func _forward_canvas_draw_over_viewport(superficie : Control) -> void:
	manijas.dibujar(superficie)


func _forward_canvas_gui_input(evento : InputEvent) -> bool:
	var consumido : bool = manijas.procesar_input(evento)
	if consumido:
		update_overlays()
	return consumido


func buscar_control_viewport() -> Control:
	var candidatos : Array[Node] = EditorInterface.get_base_control().find_children("*", "CanvasItemEditorViewport", true, false)
	if not candidatos.is_empty():
		return candidatos[0]
	return EditorInterface.get_editor_viewport_2d().get_parent()


func obtener_cargador() -> CargadorDeNivel:
	var raiz : Node = EditorInterface.get_edited_scene_root()
	if raiz is CargadorDeNivel:
		return raiz
	push_warning("La escena abierta tiene que tener un CargadorDeNivel como raiz")
	return null


func crear_forma(tipo : String) -> void:
	var cargador : CargadorDeNivel = obtener_cargador()
	var forma : Node2D
	var seleccion : EditorSelection
	if not cargador:
		return
	forma = cargador.crear_forma(tipo, cargador)
	forma.global_position = centro_del_viewport()
	seleccion = EditorInterface.get_selection()
	seleccion.clear()
	seleccion.add_node(forma)
	if forma is FormaPath:
		seleccionar_herramienta_agregar_punto.call_deferred()


func obtener_forma_seleccionada(cargador : CargadorDeNivel) -> Node2D:
	var formas : Array[Node2D] = cargador.obtener_formas()
	var actual : Node
	for nodo in EditorInterface.get_selection().get_selected_nodes():
		actual = nodo
		while actual and actual != cargador:
			if formas.has(actual):
				return actual
			actual = actual.get_parent()
	push_warning("Selecciona una forma del nivel")
	return null


func agregar_recorrido() -> void:
	var cargador : CargadorDeNivel = obtener_cargador()
	var forma : Node2D
	var recorrido : MovimientoPorPath
	var seleccion : EditorSelection
	if not cargador:
		return
	forma = obtener_forma_seleccionada(cargador)
	if not forma or cargador.obtener_recorrido(forma):
		return
	recorrido = cargador.agregar_recorrido(forma, cargador)
	seleccion = EditorInterface.get_selection()
	seleccion.clear()
	seleccion.add_node(recorrido)
	seleccionar_herramienta_agregar_punto.call_deferred()


func quitar_recorrido() -> void:
	var cargador : CargadorDeNivel = obtener_cargador()
	var forma : Node2D
	var recorrido : MovimientoPorPath
	var seleccion : EditorSelection
	if not cargador:
		return
	forma = obtener_forma_seleccionada(cargador)
	if not forma:
		return
	recorrido = cargador.obtener_recorrido(forma)
	if not recorrido:
		return
	cargador.quitar_recorrido(recorrido, cargador)
	seleccion = EditorInterface.get_selection()
	seleccion.clear()
	seleccion.add_node(forma)


func seleccionar_herramienta_agregar_punto() -> void:
	var editores : Array[Node] = EditorInterface.get_base_control().find_children("*", "Path2DEditor", true, false)
	var nombres : Array
	if editores.is_empty():
		return
	nombres = [tr("Add Point"), tr("Add Point (in empty space)")]
	for boton in editores[0].find_children("*", "Button", true, false):
		for nombre in nombres:
			if boton.tooltip_text.begins_with(nombre):
				boton.button_pressed = true
				return


func centro_del_viewport() -> Vector2:
	var viewport : SubViewport = EditorInterface.get_editor_viewport_2d()
	return viewport.global_canvas_transform.affine_inverse() * (viewport.size * 0.5)


func nuevo_nivel() -> void:
	var cargador : CargadorDeNivel = obtener_cargador()
	if not cargador:
		return
	cargador.limpiar_formas()
	dock.mostrar_nombre("")


func guardar_nivel(nombre : String) -> void:
	var cargador : CargadorDeNivel = obtener_cargador()
	var ruta : String
	var datos : NivelData
	var error : Error
	if not cargador:
		return
	if nombre.is_empty():
		nombre = "nivel"
	DirAccess.make_dir_recursive_absolute(CARPETA_NIVELES)
	ruta = CARPETA_NIVELES + nombre + ".tres"
	datos = actualizar_recurso_en_cache(cargador.exportar_nivel(nombre), ruta)
	error = ResourceSaver.save(datos, ruta)
	if error != OK:
		push_error("No se pudo guardar el nivel en " + ruta)
		return
	EditorInterface.get_resource_filesystem().scan()


func actualizar_recurso_en_cache(datos_nuevos : NivelData, ruta : String) -> NivelData:
	if not ResourceLoader.has_cached(ruta):
		datos_nuevos.take_over_path(ruta)
		return datos_nuevos
	var datos_en_cache : NivelData = ResourceLoader.load(ruta)
	datos_en_cache.nombre = datos_nuevos.nombre
	datos_en_cache.formas = datos_nuevos.formas
	datos_en_cache.emit_changed()
	return datos_en_cache


func abrir_dialogo_cargar() -> void:
	dialogo_archivo.popup_centered_ratio(0.6)


func cargar_nivel(ruta : String) -> void:
	var cargador : CargadorDeNivel = obtener_cargador()
	var datos : NivelData
	if not cargador:
		return
	datos = ResourceLoader.load(ruta, "", ResourceLoader.CACHE_MODE_IGNORE)
	if not datos:
		push_error("El archivo no es un NivelData: " + ruta)
		return
	cargador.construir_nivel(datos, cargador)
	dock.mostrar_nombre(ruta.get_file().get_basename())
