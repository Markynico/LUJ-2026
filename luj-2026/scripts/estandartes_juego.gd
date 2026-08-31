class_name EstandartesJuego
extends Node2D

##escena de la coleccion que se abre como overlay
@export var escena_coleccion : PackedScene = preload("res://escenas/coleccion.tscn")
##capa del canvas en la que se abre la coleccion, por encima de los estandartes
@export var capa_coleccion : int = 10

@export_group("Nodos")
@export var boton_opciones : BotonEstandarte
@export var boton_coleccion : BotonEstandarte
@export var boton_menu : BotonEstandarte
@export var opciones : Opciones
@export var confirmacion_menu : ConfirmationDialog
##tamaño de fuente del texto del dialogo de confirmacion
@export var tamaño_texto_confirmacion : int = 28

var coleccion : Coleccion
var capa_overlay : CanvasLayer


func _ready() -> void:
	boton_opciones.pressed.connect(opciones.show)
	boton_coleccion.pressed.connect(abrir_coleccion)
	boton_menu.pressed.connect(confirmacion_menu.popup_centered)
	confirmacion_menu.confirmed.connect(ir_al_menu)
	confirmacion_menu.get_label().add_theme_font_size_override("font_size", tamaño_texto_confirmacion)
	confirmacion_menu.get_label().horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	confirmacion_menu.get_ok_button().add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	confirmacion_menu.get_cancel_button().add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	opciones.process_mode = Node.PROCESS_MODE_ALWAYS
	opciones.visibility_changed.connect(actualizar_pausa)


func abrir_coleccion() -> void:
	if coleccion:
		return
	capa_overlay = CanvasLayer.new()
	capa_overlay.layer = capa_coleccion
	coleccion = escena_coleccion.instantiate()
	coleccion.cerrada.connect(cerrar_coleccion)
	capa_overlay.add_child(coleccion)
	add_child(capa_overlay)
	actualizar_pausa()


func cerrar_coleccion() -> void:
	capa_overlay.queue_free()
	capa_overlay = null
	coleccion = null
	actualizar_pausa()


func ir_al_menu() -> void:
	get_tree().paused = false
	GameManager.instancia_actual.volver_al_menu()


func actualizar_pausa() -> void:
	get_tree().paused = opciones.visible or coleccion != null
