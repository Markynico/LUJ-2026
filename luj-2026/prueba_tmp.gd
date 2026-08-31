extends Node

func _ready() -> void:
	Transicion.cambiar_escena_ahora("res://escenas/menu.tscn")
	await get_tree().create_timer(0.5).timeout
	Transicion.cambiar_escena_ahora("res://escenas/juego.tscn")
	await get_tree().create_timer(0.5).timeout
	print("flujo completo ok")
	get_tree().quit()
