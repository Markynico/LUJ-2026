@tool
class_name CargadorDeNivel
extends Node2D

##nivel que se construye al iniciar, si esta vacio se usan las formas que ya son hijas del nodo
@export var nivel : NivelData:
	set(valor):
		if nivel and nivel.changed.is_connected(mostrar_vista_previa):
			nivel.changed.disconnect(mostrar_vista_previa)
		nivel = valor
		if nivel:
			nivel.changed.connect(mostrar_vista_previa)
		mostrar_vista_previa()
##escenas de formas disponibles
@export var escenas_formas : Dictionary[String, PackedScene] = {
	"rectangulo": preload("uid://cformarect0a1"),
	"circulo": preload("uid://cformacirc0a1"),
	"path": preload("uid://cformabe000a1"),
}
##escena que envuelve a una forma para moverla por un recorrido
@export var escena_recorrido : PackedScene = preload("uid://crecorrido00a1")


func _ready() -> void:
	if Engine.is_editor_hint():
		mostrar_vista_previa()
	elif nivel:
		construir_nivel(nivel)


func mostrar_vista_previa() -> void:
	if not Engine.is_editor_hint() or not is_inside_tree() or es_raiz_editada():
		return
	limpiar_formas_sin_duenio()
	if nivel:
		instanciar_formas(nivel)


func es_raiz_editada() -> bool:
	return owner == null


func limpiar_formas_sin_duenio() -> void:
	for raiz in obtener_raices_de_formas():
		if raiz.owner == null:
			remove_child(raiz)
			raiz.queue_free()


func obtener_formas() -> Array[Node2D]:
	var formas : Array[Node2D] = []
	for hijo in get_children():
		if hijo is MovimientoPorPath:
			var forma : Node2D = hijo.obtener_forma()
			if forma:
				formas.append(forma)
		elif hijo.has_method("obtener_datos"):
			formas.append(hijo)
	return formas


func obtener_raices_de_formas() -> Array[Node2D]:
	var raices : Array[Node2D] = []
	for hijo in get_children():
		if hijo is MovimientoPorPath or hijo.has_method("obtener_datos"):
			raices.append(hijo)
	return raices


func limpiar_formas() -> void:
	for raiz in obtener_raices_de_formas():
		remove_child(raiz)
		raiz.queue_free()


func construir_nivel(datos_nivel : NivelData, duenio : Node = null) -> void:
	limpiar_formas()
	instanciar_formas(datos_nivel, duenio)


func instanciar_formas(datos_nivel : NivelData, duenio : Node = null) -> void:
	for datos in datos_nivel.formas:
		var forma := crear_forma(datos.tipo, duenio)
		forma.aplicar_datos(datos)
		if datos.recorrido:
			agregar_recorrido(forma, duenio).aplicar_datos(datos)


func crear_forma(tipo : String, duenio : Node = null) -> Node2D:
	var forma : Node2D = escenas_formas[tipo].instantiate()
	add_child(forma)
	if duenio:
		forma.owner = duenio
	return forma


func agregar_recorrido(forma : Node2D, duenio : Node = null) -> MovimientoPorPath:
	var recorrido : MovimientoPorPath = escena_recorrido.instantiate()
	var posicion_global := forma.global_position
	forma.get_parent().remove_child(forma)
	add_child(recorrido)
	recorrido.global_position = posicion_global
	recorrido.seguidor.add_child(forma)
	forma.position = Vector2.ZERO
	if duenio:
		recorrido.owner = duenio
		duenio.set_editable_instance(recorrido, true)
		forma.owner = duenio
	return recorrido


func quitar_recorrido(recorrido : MovimientoPorPath, duenio : Node = null) -> Node2D:
	var forma := recorrido.obtener_forma()
	var posicion_global := forma.global_position
	recorrido.seguidor.remove_child(forma)
	remove_child(recorrido)
	recorrido.queue_free()
	add_child(forma)
	forma.global_position = posicion_global
	if duenio:
		forma.owner = duenio
	return forma


func obtener_recorrido(forma : Node2D) -> MovimientoPorPath:
	var seguidor := forma.get_parent()
	if seguidor is PathFollow2D and seguidor.get_parent() is MovimientoPorPath:
		return seguidor.get_parent()
	return null


func exportar_nivel(nombre : String) -> NivelData:
	var datos_nivel := NivelData.new()
	datos_nivel.nombre = nombre
	for raiz in obtener_raices_de_formas():
		datos_nivel.formas.append(raiz.obtener_datos())
	return datos_nivel
