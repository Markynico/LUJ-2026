@tool
@icon("res://iconos_custom/fish.svg")
class_name SelectorComidas
extends Control


@export var ui_contenedor_comidas : HBoxContainer
@export var canvas_layer : CanvasLayer
const escena_panel_comida : PackedScene = preload("res://escenas/componentes/panel_comida.tscn")
@export var comidas_a_mostrar : int = 3

func _ready() -> void:
	%LabelAviso.hide()
	esconder_selector_comidas()
	elegir_comidas_aleatorias() #dsp le puedo agregar q se tenga q verificar si ya tenia tal comida para no mostrarla (?

func elegir_comidas_aleatorias():
	limpiar_comidas_anteriores()
	for comida in range(comidas_a_mostrar): #para solo elegir 3 comidas
		var nueva_comida = Global.bolas_de_pelo_existentes.pick_random()
		crear_panel_comida(nueva_comida)


func crear_panel_comida(comida_a_mostrar : PelotitaBase):
	var instancia_panel : PanelComida = escena_panel_comida.instantiate()
	instancia_panel.avanzar_comida_elegida.connect(avanzar)
	instancia_panel.set_info_comida(comida_a_mostrar)
	ui_contenedor_comidas.add_child(instancia_panel)

func limpiar_comidas_anteriores():
	#if ui_contenedor_comidas.get_child_count() <=0:
		#return
	for hijo in ui_contenedor_comidas.get_children():
		hijo.queue_free()

#la llamo con una signal desde los paneles y sino tmb desde el boton omitir con la signal de pressed
func avanzar(): #sea pq elige una comida o pq pone en omitir
	esconder_selector_comidas()


func mostrar_selector_comidas(): #2 muestro el selector y pauso el juego, pero solo la ui sigue recibiendo inputs
	#Global.eligiendo_comidas.emit() #para avisarle a game manager q cambie de estado a seleccionando comidas
	elegir_comidas_aleatorias()
	canvas_layer.show()
	Global.pausar_juego()


func esconder_selector_comidas():
	canvas_layer.hide()
	Global.reanudar_juego()

#1 cada vez q terminamoms un nivel se muestra el selector de comidas
func _on_game_manager_nivel_completado(exito: bool) -> void: #signal conectada en la escena de juego
	mostrar_selector_comidas()
