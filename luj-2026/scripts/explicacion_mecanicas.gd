class_name ExplicadorMecanicas
extends Control

var pagina_actual : int = 0
@onready var layer_explicaciones: CanvasLayer = %LayerExplicaciones
@onready var texturect_imagenes_tutoriales: TextureRect = %ImagenesTutoriales
@onready var label_cant_paginas: Label = %LabelCantPaginas
@export var lista_imagenes_explicativas : Array[Texture2D]


func _ready() -> void:
	layer_explicaciones.hide()
	hide()
	texturect_imagenes_tutoriales.texture = lista_imagenes_explicativas[0]
	label_cant_paginas.text = str(pagina_actual + 1) + " / " + str(lista_imagenes_explicativas.size())

func _on_boton_info_pressed():
	layer_explicaciones.show()
	show() #este mismo nodo tmb sino rompia todo


func _on_pagina_izq_pressed() -> void:
	print("presione pag izq, contador vale : ", pagina_actual)
	pagina_actual -= 1
	if pagina_actual < 0:
		pagina_actual = 0
		return
	texturect_imagenes_tutoriales.texture = lista_imagenes_explicativas[pagina_actual]
	label_cant_paginas.text = str(pagina_actual + 1) + " / " + str(lista_imagenes_explicativas.size())
	print("al finalizar izq, contador vale : ", pagina_actual)



func _on_pagina_der_pressed() -> void:
	print("presione pag der, contador vale : ", pagina_actual)
	pagina_actual += 1
	if pagina_actual >= lista_imagenes_explicativas.size():
		pagina_actual = lista_imagenes_explicativas.size() - 1
		return
	texturect_imagenes_tutoriales.texture = lista_imagenes_explicativas[pagina_actual]
	label_cant_paginas.text = str(pagina_actual + 1) + " / " + str(lista_imagenes_explicativas.size())
	print("al finalizar der, contador vale : ", pagina_actual)
	


func _on_boton_cerrar_pressed() -> void:
	layer_explicaciones.hide()
	hide()
