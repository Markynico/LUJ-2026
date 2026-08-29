@icon("res://iconos_custom/pie_chart.svg")
class_name UICargadorPelotitas
extends Control

@onready var vbox_pelotitas: VBoxContainer = %VboxPelotitas
@export var escena_textura_pelotita : PackedScene = preload("res://escenas/componentes/texture_rect_cargador.tscn")

func _ready() -> void:
	Global.cargador_pelotitas_actualizado.connect(_on_cargador_pelotitas_actualizado)
	#await get_tree().create_timer(1).timeout
	_on_cargador_pelotitas_actualizado()


func _on_cargador_pelotitas_actualizado():
	limpiar_cargador()
	var cargador_actual : Array[PelotitaBase]= Global.get_cargador_de_pelotitas()
	for pelotita in cargador_actual:
		var instancia_imagen : TextureRect = escena_textura_pelotita.instantiate()
		instancia_imagen.texture = pelotita.textura
		vbox_pelotitas.add_child(instancia_imagen)

func limpiar_cargador():
	for nodo in vbox_pelotitas.get_children():
		nodo.queue_free()
