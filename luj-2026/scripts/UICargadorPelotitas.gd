@icon("res://iconos_custom/pie_chart.svg")
class_name UICargadorPelotitas
extends Sprite2D

@onready var vbox_pelotitas: VBoxContainer = %VboxPelotitas
@onready var label_contador: Label = %LabelContador
@export var escena_textura_pelotita : PackedScene 
#var contador : int = 0 #para poner en el label nomas

func _ready() -> void:
	Global.cargador_pelotitas_actualizado.connect(_on_cargador_pelotitas_actualizado)
	#await get_tree().create_timer(1).timeout
	_on_cargador_pelotitas_actualizado()


func _on_cargador_pelotitas_actualizado():
	limpiar_cargador()
	var cargador_actual : Array[PelotitaBase]= Global.get_cargador_de_pelotitas()
	for pelotita in cargador_actual:
		#print("cargador actual vale: ", cargador_actual , " y pelotita vale: ", pelotita)
		var instancia_imagen : TextureRectCargadorBolas = escena_textura_pelotita.instantiate()
		instancia_imagen.texture = pelotita.textura
		vbox_pelotitas.add_child(instancia_imagen)
		#instancia_imagen.set_texto_bolapelos(pelotita)
	label_contador.text = str(cargador_actual.size())

func limpiar_cargador():
	for nodo in vbox_pelotitas.get_children():
		nodo.queue_free()
