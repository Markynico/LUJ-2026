@tool
@icon("res://iconos_custom/pie_chart.svg")
class_name UICargadorPelotitas
extends Sprite2D

##escena de cada imagen de pelotita del cargador
@export var escena_textura_pelotita : PackedScene
##margen del fondo alrededor del contenido, puede ser negativo porque el stylebox se expande 15 y 10 px por lado
@export var margen_fondo : Vector2 = Vector2(-11, -6)

@export_group("Tarjeta de hover")
##escena de la tarjeta que se muestra al hacer hover
@export var escena_tarjeta : PackedScene = preload("uid://u6k76f6lyw8y")
##posicion en pantalla de la tarjeta de hover
@export var posicion_tarjeta : Vector2 = Vector2(430, 200)
##escala de la tarjeta de hover
@export var escala_tarjeta : float = 1.2

@onready var sub_viewport : SubViewport = $SubViewportCargador
@onready var contenedor : VBoxContainer = $SubViewportCargador/ContenedorNomas
@onready var vbox_pelotitas : VBoxContainer = %VboxPelotitas
@onready var label_contador : Label = %LabelContador
@onready var cuadro_fondo : Panel = %CuadroFondo

var rects : Array[TextureRect] = []
var pelotitas_mostradas : Array[PelotitaBase] = []
var tarjeta : Tarjeta
var pelotita_hover : PelotitaBase


func _ready() -> void:
	if Engine.is_editor_hint():
		ajustar_fondo()
		return
	crear_tarjeta()
	Global.cargador_pelotitas_actualizado.connect(_on_cargador_pelotitas_actualizado)
	_on_cargador_pelotitas_actualizado()


func _input(evento : InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	if evento is InputEventMouseMotion:
		revisar_hover()


func crear_tarjeta() -> void:
	var capa : CanvasLayer = CanvasLayer.new()
	tarjeta = escena_tarjeta.instantiate()
	tarjeta.hover_activado = false
	tarjeta.position = posicion_tarjeta
	tarjeta.scale = Vector2.ONE * escala_tarjeta
	tarjeta.hide()
	capa.add_child(tarjeta)
	add_child(capa)


func _on_cargador_pelotitas_actualizado() -> void:
	var cargador_actual : Array[PelotitaBase] = Global.get_cargador_de_pelotitas()
	var instancia_imagen : TextureRect
	limpiar_cargador()
	for pelotita in cargador_actual:
		instancia_imagen = escena_textura_pelotita.instantiate()
		instancia_imagen.texture = pelotita.textura
		vbox_pelotitas.add_child(instancia_imagen)
		rects.append(instancia_imagen)
		pelotitas_mostradas.append(pelotita)
	label_contador.text = str(cargador_actual.size())
	ajustar_fondo()


func limpiar_cargador() -> void:
	for nodo in vbox_pelotitas.get_children():
		nodo.queue_free()
	rects.clear()
	pelotitas_mostradas.clear()


func ajustar_fondo() -> void:
	var contenido : Vector2
	if not cuadro_fondo:
		return
	await get_tree().process_frame
	contenido = contenedor.get_combined_minimum_size()
	cuadro_fondo.size = contenido + margen_fondo * 2.0
	cuadro_fondo.position = contenedor.position + contenedor.size * 0.5 - cuadro_fondo.size * 0.5


func revisar_hover() -> void:
	var punto : Vector2 = to_local(get_global_mouse_position()) + Vector2(sub_viewport.size) * 0.5
	var bajo_mouse : PelotitaBase = null
	for i in rects.size():
		if is_instance_valid(rects[i]) and rects[i].get_global_rect().has_point(punto):
			bajo_mouse = pelotitas_mostradas[i]
			break
	if bajo_mouse == pelotita_hover:
		return
	pelotita_hover = bajo_mouse
	if pelotita_hover:
		tarjeta.recurso = pelotita_hover
		tarjeta.aparecer()
	else:
		tarjeta.desaparecer()
