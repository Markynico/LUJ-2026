@tool
class_name GeneradorDeOvillos
extends Node2D

##escena que se instancia en cada punto de la forma
@export var escena_spawn : PackedScene = preload("uid://4u6vlkjfcunf")
##forma de la cual se toman los puntos, normalmente el nodo padre
@export var forma : FormaSpawn


func _ready() -> void:
	if not forma:
		forma = get_parent() as FormaSpawn
	if not forma:
		return
	forma.forma_cambiada.connect(regenerar)
	regenerar()


func regenerar() -> void:
	for hijo in get_children():
		remove_child(hijo)
		hijo.queue_free()
	if not forma or not escena_spawn:
		return
	for punto in forma.obtener_puntos():
		var spawn := escena_spawn.instantiate()
		spawn.position = punto
		add_child(spawn)
