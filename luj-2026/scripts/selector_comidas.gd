@tool
@icon("res://iconos_custom/fish.svg")
class_name SelectorComidas
extends Control

signal seleccion_terminada


@export var ui_contenedor_comidas : HBoxContainer
@export var canvas_layer : CanvasLayer
@export var foco : FocoTarjetas
const escena_tarjeta : PackedScene = preload("uid://u6k76f6lyw8y")
@export var comidas_a_mostrar : int = 3
##escala de las tarjetas de comida
@export var escala_tarjeta : float = 0.85
##tamaño base de la tarjeta
@export var tamaño_tarjeta : Vector2 = Vector2(500, 600)

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	%LabelAviso.hide()
	foco.accion_pedida.connect(elegir_en_foco)
	esconder_selector_comidas()
	elegir_comidas_aleatorias() #dsp le puedo agregar q se tenga q verificar si ya tenia tal comida para no mostrarla (?

func elegir_comidas_aleatorias():
	limpiar_comidas_anteriores()
	for comida in range(comidas_a_mostrar): #para solo elegir 3 comidas
		var nueva_comida = Global.bolas_de_pelo_existentes.pick_random()
		crear_panel_comida(nueva_comida)


func crear_panel_comida(comida_a_mostrar : PelotitaBase):
	var envoltura : Control = Control.new()
	var tarjeta : Tarjeta = escena_tarjeta.instantiate()
	var boton : Button
	var precio : int = Rareza.precio_de(comida_a_mostrar)
	envoltura.custom_minimum_size = tamaño_tarjeta * escala_tarjeta
	tarjeta.size = tamaño_tarjeta
	tarjeta.scale = Vector2.ONE * escala_tarjeta
	tarjeta.recurso = comida_a_mostrar
	envoltura.add_child(tarjeta)
	ui_contenedor_comidas.add_child(envoltura)
	boton = tarjeta.mostrar_boton_precio(precio)
	boton.disabled = Global.monedas < precio
	boton.pressed.connect(elegir_comida.bind(comida_a_mostrar))
	tarjeta.clickeada.connect(al_click_tarjeta.bind(tarjeta, boton))


func al_click_tarjeta(tarjeta : Tarjeta, boton : Button) -> void:
	if foco.esta_abierto():
		return
	tarjeta.estilizar_boton_precio(foco.boton_accion, Rareza.precio_de(tarjeta.recurso))
	foco.boton_accion.disabled = boton.disabled
	foco.con_accion = true
	foco.abrir(tarjeta, boton.get_parent())


func elegir_en_foco(tarjeta : Tarjeta) -> void:
	elegir_comida(tarjeta.recurso)


func elegir_comida(comida : PelotitaBase) -> void:
	var precio : int = Rareza.precio_de(comida)
	if Global.monedas < precio:
		return
	Global.actualizar_monedas(-precio)
	Global.actualizar_comidas_elegidas(comida)
	avanzar()

func limpiar_comidas_anteriores():
	#if ui_contenedor_comidas.get_child_count() <=0:
		#return
	for hijo in ui_contenedor_comidas.get_children():
		hijo.queue_free()

#la llamo con una signal desde los paneles y sino tmb desde el boton omitir con la signal de pressed
func avanzar(): #sea pq elige una comida o pq pone en omitir
	esconder_selector_comidas()
	seleccion_terminada.emit()


func mostrar_selector_comidas(): #2 muestro el selector y pauso el juego, pero solo la ui sigue recibiendo inputs
	#Global.eligiendo_comidas.emit() #para avisarle a game manager q cambie de estado a seleccionando comidas
	elegir_comidas_aleatorias()
	canvas_layer.show()
	Transicion.filtrar_musica(true)


func esconder_selector_comidas():
	canvas_layer.hide()
	Transicion.filtrar_musica(false)

#1 cada vez q terminamoms un nivel se muestra el selector de comidas
func _on_game_manager_nivel_completado(exito: bool) -> void: #signal conectada en la escena de juego
	mostrar_selector_comidas()
