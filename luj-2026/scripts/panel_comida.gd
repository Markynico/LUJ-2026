@tool
class_name PanelComida
extends Panel
#dejo q el panel se encargue de saber que comida elegimos, el selector solo contiene toda la info + ui

@export var textura_comida : TextureRect
var comida_asociada : EfectosPelotita
signal avanzar_comida_elegida

func set_info_comida(comida : EfectosPelotita):
	comida_asociada = comida
	textura_comida.texture = comida.imagen_comida_asociada


func _on_button_elegir_pressed() -> void:
	#TODO aca meterle sonidito o signal para el sound manager
	Global.actualizar_comidas_elegidas(comida_asociada)
	avanzar_comida_elegida.emit()
