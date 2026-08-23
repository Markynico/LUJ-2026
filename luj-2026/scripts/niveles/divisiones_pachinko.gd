@tool
class_name DivisionesPachinko
extends Node2D

##cantidad de divisores entre los dos de los costados
@export_range(0, 20, 1) var divisiones_intermedias : int = 2:
	set(valor):
		divisiones_intermedias = valor
		pedir_regenerar()
##distancia entre el primer y el ultimo divisor
@export var ancho_total : float = 1280.0:
	set(valor):
		ancho_total = max(valor, 1.0)
		pedir_regenerar()
@export var escena_divisor : PackedScene = preload("uid://cdivisor000a1"):
	set(valor):
		if escena_divisor and escena_divisor.changed.is_connected(pedir_regenerar):
			escena_divisor.changed.disconnect(pedir_regenerar)
		escena_divisor = valor
		if escena_divisor:
			escena_divisor.changed.connect(pedir_regenerar)
		pedir_regenerar()

var regeneracion_pendiente : bool = false


func _ready() -> void:
	if escena_divisor and not escena_divisor.changed.is_connected(pedir_regenerar):
		escena_divisor.changed.connect(pedir_regenerar)
	regenerar()


func pedir_regenerar() -> void:
	if regeneracion_pendiente or not is_inside_tree():
		return
	regeneracion_pendiente = true
	regenerar.call_deferred()


func regenerar() -> void:
	regeneracion_pendiente = false
	for hijo in get_children():
		remove_child(hijo)
		hijo.queue_free()
	if not escena_divisor:
		return
	var cantidad := divisiones_intermedias + 2
	for i in cantidad:
		var divisor := escena_divisor.instantiate()
		divisor.position = Vector2(ancho_total * i / (cantidad - 1), 0)
		add_child(divisor)
