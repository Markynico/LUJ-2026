@tool
class_name CuadroUI
extends Control

##radio de las 4 esquinas del fondo en pixeles
@export var radio_esquinas : int = 40:
	set(valor):
		radio_esquinas = maxi(valor, 0)
		aplicar_radio()
@export var mascara_fondo : Panel
@export var marco : NinePatchRect
##color con el que se tiñe el marco
@export var color_marco : Color = Color.WHITE:
	set(color):
		color_marco = color
		aplicar_color()


func _ready() -> void:
	aplicar_radio()
	aplicar_color()


func aplicar_color() -> void:
	if marco:
		marco.self_modulate = color_marco


func aplicar_radio() -> void:
	var estilo : StyleBoxFlat
	if not mascara_fondo:
		return
	estilo = mascara_fondo.get_theme_stylebox("panel")
	estilo.corner_radius_top_left = radio_esquinas
	estilo.corner_radius_top_right = radio_esquinas
	estilo.corner_radius_bottom_right = radio_esquinas
	estilo.corner_radius_bottom_left = radio_esquinas
