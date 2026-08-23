@tool
class_name GeneradorDeOvillos
extends Node2D

##escena que se instancia en cada punto de la forma
@export var escena_spawn : PackedScene = preload("uid://4u6vlkjfcunf")
##forma de la cual se toman los puntos globales, normalmente el nodo padre, tiene que tener obtener_puntos() y la señal forma_cambiada
@export var forma : Node2D

var regeneracion_pendiente : bool = false


func _ready() -> void:
	set_as_top_level(true)
	if not forma:
		forma = get_parent() as Node2D
	if not forma or not forma.has_method("obtener_puntos"):
		return
	forma.forma_cambiada.connect(pedir_regenerar)
	regenerar()


func pedir_regenerar() -> void:
	if regeneracion_pendiente:
		return
	regeneracion_pendiente = true
	regenerar.call_deferred()


func regenerar() -> void:
	regeneracion_pendiente = false
	for hijo in get_children():
		remove_child(hijo)
		hijo.queue_free()
	if not forma or not escena_spawn:
		return
	for punto in forma.obtener_puntos():
		var spawn := escena_spawn.instantiate()
		add_child(spawn)
		spawn.global_position = punto
