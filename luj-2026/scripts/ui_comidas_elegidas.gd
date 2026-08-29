@icon("res://iconos_custom/fish_2.svg")
class_name UIComidasElegidas
extends Sprite2D

@export var item_list : ItemList

func _ready() -> void:
	Global.eligio_una_comida.connect(_on_eligio_una_comida)


func _on_eligio_una_comida():
	item_list.clear()
	for comida in Global.comidas_elegidas:
		agregar_item(comida)

func agregar_item(comida_nueva : PelotitaBase):
	#item_list.add_item(comida.nombre_comida, comida.imagen_comida_asociada, false)
	item_list.add_item(comida_nueva.nombre, comida_nueva.imagen_comida_asociada, false)
