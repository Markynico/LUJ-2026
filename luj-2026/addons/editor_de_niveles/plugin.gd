@tool
extends EditorPlugin

const ESCENA_DOCK := preload("uid://bdockeditortsc1")
const SCRIPT_SIMETRIA := preload("res://addons/editor_de_niveles/simetria_niveles.gd")
const CARPETA_NIVELES := "res://niveles/"
const ESCENA_JUEGO := "uid://hli2qjvrii4o"

var dock : DockEditorDeNiveles
var manijas : ManijasForma
var dialogo_archivo : EditorFileDialog
var selector : SelectorDeFormas
var selector_ovillos : SelectorDeOvillos
var duplicador : DuplicadorDeFormas
var simetria : SimetriaNiveles


func _enter_tree() -> void:
	dock = ESCENA_DOCK.instantiate()
	dock.crear_forma.connect(crear_forma)
	dock.nuevo_nivel.connect(nuevo_nivel)
	dock.guardar_nivel.connect(guardar_nivel)
	dock.cargar_nivel.connect(abrir_dialogo_cargar)
	dock.agregar_recorrido.connect(agregar_recorrido)
	dock.quitar_recorrido.connect(quitar_recorrido)
	dock.simetria_cambiada.connect(actualizar_simetria)
	dock.previsualizacion_cambiada.connect(actualizar_previsualizacion)
	dock.seleccion_ovillos_cambiada.connect(activar_seleccion_ovillos)
	dock.eliminar_ovillos.connect(eliminar_ovillos)
	dock.restaurar_ovillos.connect(restaurar_ovillos)
	dock.probar_nivel.connect(probar_nivel)
	scene_changed.connect(al_cambiar_escena)
	set_force_draw_over_forwarding_enabled()
	add_control_to_dock(DOCK_SLOT_LEFT_UL, dock)
	manijas = ManijasForma.new(get_undo_redo())
	selector_ovillos = SelectorDeOvillos.new(self, buscar_control_viewport(), get_undo_redo())
	EditorInterface.get_base_control().add_child(selector_ovillos)
	selector = SelectorDeFormas.new(manijas, self, buscar_control_viewport())
	selector.selector_ovillos = selector_ovillos
	EditorInterface.get_base_control().add_child(selector)
	duplicador = DuplicadorDeFormas.new(buscar_control_viewport())
	duplicador.duplicar_pedido.connect(duplicar_forma)
	EditorInterface.get_base_control().add_child(duplicador)
	dialogo_archivo = EditorFileDialog.new()
	dialogo_archivo.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	dialogo_archivo.access = EditorFileDialog.ACCESS_RESOURCES
	dialogo_archivo.add_filter("*.tres", "Nivel")
	dialogo_archivo.current_dir = CARPETA_NIVELES
	dialogo_archivo.file_selected.connect(cargar_nivel)
	EditorInterface.get_base_control().add_child(dialogo_archivo)


func _exit_tree() -> void:
	FormaSpawn.previsualizar_movimiento = false
	if simetria and is_instance_valid(simetria):
		simetria.queue_free()
	remove_control_from_docks(dock)
	dock.queue_free()
	dialogo_archivo.queue_free()
	selector.queue_free()
	selector_ovillos.queue_free()
	duplicador.queue_free()


func _handles(objeto : Object) -> bool:
	return objeto is FormaSpawn


func _edit(objeto : Object) -> void:
	manijas.forma = objeto as FormaSpawn
	update_overlays()


func _forward_canvas_draw_over_viewport(superficie : Control) -> void:
	manijas.dibujar(superficie)


func _forward_canvas_force_draw_over_viewport(superficie : Control) -> void:
	selector_ovillos.dibujar(superficie)


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
	if simetria_activa():
		simetria.registrar_nueva(forma)
	seleccion = EditorInterface.get_selection()
	seleccion.clear()
	seleccion.add_node(forma)
	if forma is FormaPath:
		seleccionar_herramienta_agregar_punto.call_deferred()


func obtener_forma_seleccionada(cargador : CargadorDeNivel) -> Node2D:
	var forma : Node2D = duplicador.buscar_forma_seleccionada(cargador)
	if not forma:
		push_warning("Selecciona una forma del nivel")
	return forma


func raiz_de(cargador : CargadorDeNivel, forma : Node2D) -> Node2D:
	var recorrido : MovimientoPorPath = cargador.obtener_recorrido(forma)
	return recorrido if recorrido else forma


func duplicar_forma(forma : Node2D) -> void:
	var cargador : CargadorDeNivel = obtener_cargador()
	var raiz : Node2D
	var datos : FormaData
	var copia : Node2D
	var raiz_copia : Node2D
	var nodos : Array[Node2D] = []
	var seleccion : EditorSelection
	if not cargador:
		return
	raiz = raiz_de(cargador, forma)
	datos = raiz.obtener_datos()
	datos.grupo_simetria = 0
	datos.rol_simetria = Vector2i.ZERO
	copia = cargador.crear_forma(datos.tipo, cargador)
	copia.aplicar_datos(datos)
	raiz_copia = copia
	if raiz is MovimientoPorPath:
		raiz_copia = cargador.agregar_recorrido(copia, cargador)
		raiz_copia.aplicar_datos(datos)
	raiz_copia.global_position += posicion_del_mouse() - copia.global_position
	nodos.append(raiz_copia)
	if simetria_activa():
		nodos.append_array(simetria.registrar_nueva(copia))
	registrar_creacion("Duplicar forma", cargador, nodos)
	seleccion = EditorInterface.get_selection()
	seleccion.clear()
	seleccion.add_node(copia)


func registrar_creacion(nombre : String, cargador : CargadorDeNivel, nodos : Array[Node2D]) -> void:
	var deshacer_rehacer : EditorUndoRedoManager = get_undo_redo()
	deshacer_rehacer.create_action(nombre)
	for nodo in nodos:
		deshacer_rehacer.add_do_reference(nodo)
		deshacer_rehacer.add_do_method(self, "reinsertar", cargador, nodo)
		deshacer_rehacer.add_undo_method(cargador, "remove_child", nodo)
	deshacer_rehacer.commit_action(false)


func reinsertar(cargador : CargadorDeNivel, nodo : Node2D) -> void:
	cargador.add_child(nodo)
	nodo.owner = cargador
	if nodo is MovimientoPorPath:
		cargador.set_editable_instance(nodo, true)
		if nodo.obtener_forma():
			nodo.obtener_forma().owner = cargador


func posicion_del_mouse() -> Vector2:
	var viewport : SubViewport = EditorInterface.get_editor_viewport_2d()
	var posicion : Vector2 = viewport.get_mouse_position()
	if not Rect2(Vector2.ZERO, viewport.size).has_point(posicion):
		return centro_del_viewport()
	return viewport.global_canvas_transform.affine_inverse() * posicion


func activar_seleccion_ovillos(activa : bool) -> void:
	selector_ovillos.activar(activa)


func eliminar_ovillos() -> void:
	selector_ovillos.eliminar_seleccion()


func restaurar_ovillos() -> void:
	var cargador : CargadorDeNivel = obtener_cargador()
	if not cargador:
		return
	selector_ovillos.restaurar(obtener_forma_seleccionada(cargador))


func probar_nivel(nombre : String) -> void:
	var cargador : CargadorDeNivel = obtener_cargador()
	var datos : NivelData
	if not cargador or not guardar_nivel(nombre):
		return
	datos = cargador.exportar_nivel(nombre if not nombre.is_empty() else "nivel")
	if ResourceSaver.save(datos, CargadorDeNivel.RUTA_NIVEL_PRUEBA) != OK:
		push_error("No se pudo escribir el nivel de prueba en " + CargadorDeNivel.RUTA_NIVEL_PRUEBA)
		return
	EditorInterface.play_custom_scene(ResourceUID.get_id_path(ResourceUID.text_to_id(ESCENA_JUEGO)))


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


func actualizar_previsualizacion(activa : bool) -> void:
	var cargador : CargadorDeNivel = obtener_cargador()
	var forma : Node2D
	FormaSpawn.previsualizar_movimiento = activa
	if activa or not cargador:
		return
	for raiz in cargador.obtener_raices_de_formas():
		forma = raiz
		if raiz is MovimientoPorPath:
			raiz.sentido = -1.0 if raiz.invertido else 1.0
			raiz.actualizar_seguidor()
			forma = raiz.obtener_forma()
		if forma and "fase_desplazamiento" in forma:
			forma.fase_desplazamiento = 0.0
			forma.actualizar()


func al_cambiar_escena(raiz : Node) -> void:
	if not dock or not (dock.toggle_simetria_horizontal.button_pressed or dock.toggle_simetria_vertical.button_pressed):
		return
	if simetria and is_instance_valid(simetria):
		simetria.queue_free()
		simetria = null
	if raiz is CargadorDeNivel:
		actualizar_simetria(dock.toggle_simetria_horizontal.button_pressed, dock.toggle_simetria_vertical.button_pressed)


func simetria_activa() -> bool:
	return simetria != null and is_instance_valid(simetria) and simetria.activa()


func actualizar_simetria(horizontal : bool, vertical : bool) -> void:
	var cargador : CargadorDeNivel = obtener_cargador()
	if simetria and is_instance_valid(simetria) and (not cargador or simetria.get_parent() != cargador or not (horizontal or vertical)):
		simetria.queue_free()
		simetria = null
	if not cargador or not (horizontal or vertical):
		return
	if not simetria:
		simetria = SCRIPT_SIMETRIA.new()
		simetria.cargador = cargador
		cargador.add_child(simetria)
	simetria.configurar(horizontal, vertical)


func centro_del_viewport() -> Vector2:
	var viewport : SubViewport = EditorInterface.get_editor_viewport_2d()
	return viewport.global_canvas_transform.affine_inverse() * (viewport.size * 0.5)


func nuevo_nivel() -> void:
	var cargador : CargadorDeNivel = obtener_cargador()
	if not cargador:
		return
	cargador.limpiar_formas()
	dock.mostrar_nombre("")


func guardar_nivel(nombre : String) -> bool:
	var cargador : CargadorDeNivel = obtener_cargador()
	var ruta : String
	var datos : NivelData
	var error : Error
	if not cargador:
		return false
	if nombre.is_empty():
		nombre = "nivel"
	DirAccess.make_dir_recursive_absolute(CARPETA_NIVELES)
	ruta = CARPETA_NIVELES + nombre + ".tres"
	datos = cargador.exportar_nivel(nombre)
	if datos.formas.has(null):
		push_error("Alguna forma exporto datos nulos, no se guarda el nivel. Recarga el proyecto y proba de nuevo")
		return false
	datos = actualizar_recurso_en_cache(datos, ruta)
	error = ResourceSaver.save(datos, ruta)
	if error != OK:
		push_error("No se pudo guardar el nivel en " + ruta)
		return false
	EditorInterface.get_resource_filesystem().scan()
	return true


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
	if simetria_activa():
		simetria.emparejar_existentes()
