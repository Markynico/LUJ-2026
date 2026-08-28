class_name Menu
extends Node2D

##escena que se carga al confirmar el gato
@export_file("*.tscn") var escena_juego : String = "uid://hli2qjvrii4o"
##gatos disponibles para elegir
@export var gatos : Array[DatosGato]

@export_group("Camara")
##zoom de la camara durante la seleccion de gato
@export var zoom_seleccion : Vector2 = Vector2(2.0, 2.0)
##segundos que tarda el movimiento de camara
@export var duracion_zoom : float = 1.2
##segundos que tarda el fade del panel de seleccion
@export var duracion_fade_panel : float = 0.3
@export var camara : Camera2D
@export var foco_seleccion : Marker2D

@export_group("Botones")
@export var boton_jugar : Button
@export var boton_opciones : Button
@export var boton_salir : Button

@export_group("Seleccion de gato")
@export var panel_info : Control
@export var label_nombre : Label
@export var label_descripcion : Label
@export var boton_confirmar : Button
@export var boton_volver : Button

@export_group("Opciones")
@export var opciones : Opciones

var gato_actual : int = 0
var posicion_inicial : Vector2
var zoom_inicial : Vector2
var en_seleccion : bool = false
var tween : Tween
var tween_panel : Tween


func _ready() -> void:
	AudioManager.reproducir_musica(AudioManager.musica_menu)
	posicion_inicial = camara.global_position
	zoom_inicial = camara.zoom
	panel_info.visible = false
	boton_jugar.pressed.connect(abrir_seleccion)
	boton_opciones.pressed.connect(opciones.show)
	boton_salir.pressed.connect(salir)
	boton_confirmar.pressed.connect(confirmar)
	boton_volver.pressed.connect(cerrar_seleccion)
	mostrar_gato()


func mostrar_gato() -> void:
	var datos : DatosGato
	if gatos.is_empty():
		return
	datos = gatos[gato_actual]
	label_nombre.text = datos.nombre
	label_descripcion.text = datos.descripcion


func _unhandled_input(evento : InputEvent) -> void:
	if en_seleccion and evento.is_action_pressed("ui_cancel"):
		cerrar_seleccion()


func abrir_seleccion() -> void:
	en_seleccion = true
	habilitar_botones_menu(false)
	mover_camara(foco_seleccion.global_position, zoom_seleccion)
	tween.chain().tween_callback(mostrar_panel.bind(true))


func cerrar_seleccion() -> void:
	en_seleccion = false
	mostrar_panel(false)
	mover_camara(posicion_inicial, zoom_inicial)
	tween.chain().tween_callback(habilitar_botones_menu.bind(true))


func confirmar() -> void:
	if not gatos.is_empty():
		Global.gato_elegido = gatos[gato_actual]
	get_tree().change_scene_to_file(escena_juego)


func salir() -> void:
	get_tree().quit()


func mover_camara(posicion : Vector2, zoom : Vector2) -> void:
	if tween:
		tween.kill()
	tween = create_tween().set_parallel().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(camara, "global_position", posicion, duracion_zoom)
	tween.tween_property(camara, "zoom", zoom, duracion_zoom)


func mostrar_panel(visible_panel : bool) -> void:
	if tween_panel:
		tween_panel.kill()
	tween_panel = create_tween()
	if visible_panel:
		panel_info.modulate.a = 0.0
		panel_info.visible = true
		tween_panel.tween_property(panel_info, "modulate:a", 1.0, duracion_fade_panel)
	else:
		tween_panel.tween_property(panel_info, "modulate:a", 0.0, duracion_fade_panel)
		tween_panel.tween_callback(panel_info.hide)


func habilitar_botones_menu(habilitar : bool) -> void:
	for boton in get_children():
		if boton is BotonEstandarte:
			boton.mouse_filter = Control.MOUSE_FILTER_STOP if habilitar else Control.MOUSE_FILTER_IGNORE
