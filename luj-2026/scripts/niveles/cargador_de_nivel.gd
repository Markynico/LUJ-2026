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
}


func _ready() -> void:
	if Engine.is_editor_hint():
		mostrar_vista_previa()
	elif nivel:
		construir_nivel(nivel)


func mostrar_vista_previa() -> void:
	if not Engine.is_editor_hint() or not is_inside_tree():
		return
	limpiar_formas_sin_duenio()
	if nivel:
		construir_nivel(nivel)


func limpiar_formas_sin_duenio() -> void:
	for forma in obtener_formas():
		if forma.owner == null:
			remove_child(forma)
			forma.queue_free()


func obtener_formas() -> Array[FormaSpawn]:
	var formas : Array[FormaSpawn] = []
	for hijo in get_children():
		if hijo is FormaSpawn:
			formas.append(hijo)
	return formas


func limpiar_formas() -> void:
	for forma in obtener_formas():
		remove_child(forma)
		forma.queue_free()


func construir_nivel(datos_nivel : NivelData, duenio : Node = null) -> void:
	limpiar_formas()
	for datos in datos_nivel.formas:
		crear_forma(datos.tipo, duenio).aplicar_datos(datos)


func crear_forma(tipo : String, duenio : Node = null) -> FormaSpawn:
	var forma : FormaSpawn = escenas_formas[tipo].instantiate()
	add_child(forma)
	if duenio:
		forma.owner = duenio
	return forma


func exportar_nivel(nombre : String) -> NivelData:
	var datos_nivel := NivelData.new()
	datos_nivel.nombre = nombre
	for forma in obtener_formas():
		datos_nivel.formas.append(forma.obtener_datos())
	return datos_nivel
