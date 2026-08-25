extends Node

func _ready() -> void:
	var escena : Node = load("res://escenas/prueba_escena.tscn").instantiate()
	add_child(escena)
	await get_tree().physics_frame
	var lista : Array = []
	buscar_ovillos(escena, lista)
	var ovillo : Ovillo = lista[0]
	var gato : Gato = escena.get_node("Gato")
	print("gato capa=", gato.collision_layer, " mask=", gato.collision_mask)
	gato.global_position = ovillo.global_position + Vector2(-300, -300)
	gato.velocidad_inicial = Vector2(-300, -300)
	gato.lanzar()
	await get_tree().create_timer(1.0).timeout
	print("gato lanzado en diagonal: pos=", gato.global_position.snappedf(1), " ovillo=", ovillo.global_position.snappedf(1), " distancia=", snappedf(gato.global_position.distance_to(ovillo.global_position), 0.1))
	get_tree().quit()

func buscar_ovillos(nodo : Node, lista : Array) -> void:
	if nodo is Ovillo:
		lista.append(nodo)
	for hijo in nodo.get_children():
		buscar_ovillos(hijo, lista)
