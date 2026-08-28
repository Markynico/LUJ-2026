@tool
@icon("res://iconos_custom/fish.svg")
class_name SelectorComidas
extends Control

##aca pongamos los resource de todas las bolitas de pelo q existen (bueno de los efectos en realidad), no importa el orden pq despues uso otro array para elegir y ordenar
@export var bolas_de_pelo_existentes : Array[EfectosPelotita]
@export var ui_contenedor_comidas : HBoxContainer
@export var canvas_layer : CanvasLayer
var listado_comidas_a_elegir : Array[EfectosPelotita]
const escena_panel_comida : PackedScene = preload("res://escenas/componentes/panel_comida.tscn")
@export var comidas_a_mostrar : int = 3

func _ready() -> void:
	%LabelAviso.hide()
	esconder_selector_comidas()
	elegir_comidas_aleatorias() #dsp se tiene q verificar si ya tenia tal comida para no mostrarla (?

func elegir_comidas_aleatorias():
	limpiar_comidas_anteriores()
	for comida in range(comidas_a_mostrar): #para solo elegir 3 comidas
		var nueva_comida = bolas_de_pelo_existentes.pick_random() #aleatoria
		listado_comidas_a_elegir.append(nueva_comida)
		crear_panel_comida(nueva_comida)


func crear_panel_comida(comida_a_mostrar : EfectosPelotita):
	var instancia_panel : PanelComida = escena_panel_comida.instantiate()
	instancia_panel.avanzar_comida_elegida.connect(avanzar)
	instancia_panel.set_info_comida(comida_a_mostrar)
	ui_contenedor_comidas.add_child(instancia_panel)

func limpiar_comidas_anteriores():
	listado_comidas_a_elegir.clear()
	#if ui_contenedor_comidas.get_child_count() <=0:
		#return
	for hijo in ui_contenedor_comidas.get_children():
		hijo.queue_free()

#la llamo con una signal desde los paneles y sino tmb desde el boton omitir con la signal de pressed
func avanzar(): #sea pq elige una comida o pq pone en omitir
	#print("avanzarrrrrrrrrrrrrr")
	esconder_selector_comidas()
	#get_tree().change_scene_to_file("res://escenas/juego.tscn") #TODO por ahora para testear pero debe enviarte al siguiente nivel no?


func mostrar_selector_comidas(): 
	elegir_comidas_aleatorias()
	canvas_layer.show()


func esconder_selector_comidas():
	canvas_layer.hide()


func _on_game_manager_nivel_completado(exito: bool) -> void: #la llamo con signal s
	mostrar_selector_comidas()
