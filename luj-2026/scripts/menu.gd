class_name Menu
extends Node2D

##escena que se carga al confirmar el gato
@export_file("*.tscn") var escena_juego : String = "uid://hli2qjvrii4o"
##escena de la coleccion
@export_file("*.tscn") var escena_coleccion : String = "res://escenas/coleccion.tscn"
##gatos disponibles para elegir
@export var gatos : Array[DatosGato]
##dificultades entre las que se elige antes de la run
@export var dificultades : Array[DificultadRun]

@export_group("Camara")
##zoom de la camara durante la seleccion de gato
@export var zoom_seleccion : Vector2 = Vector2(2.0, 2.0)
##segundos que tarda el movimiento de camara
@export var duracion_zoom : float = 1.2
##segundos que tarda el fade del panel de seleccion
@export var duracion_fade_panel : float = 0.3
##segundos que tarda el fade del ronroneo en la seleccion
@export var duracion_fade_purr : float = 0.8
@export var camara : Camera2D
@export var foco_seleccion : Marker2D

@export_group("Botones")
@export var boton_jugar : Button
@export var boton_coleccion : Button
@export var boton_opciones : Button
@export var boton_salir : Button

@export_group("Seleccion de gato")
@export var panel_info : Control
@export var label_nombre : Label
@export var label_descripcion : Label
@export var boton_confirmar : Button
@export var boton_volver : Button
@export var brillo_seleccion : ColorRect

@export_group("Seleccion de dificultad")
@export var contenedor_dificultades : BoxContainer
##alto en pixeles de los botones de dificultad, el ancho sale de la proporcion del icono
@export var tamaño_boton_dificultad : float = 110.0
##grosor del contorno de la dificultad seleccionada
@export var grosor_borde_dificultad : float = 5.0
##shader que dibuja el contorno siguiendo el sprite
@export var shader_contorno : Shader = preload("res://scripts/shaders/contorno_seleccion.gdshader")

@export_group("Opciones")
@export var opciones : Opciones

@export_group("Guante")
@export var guante_caricia : GuanteCaricia
@export var gato_menu : Gato
##decibeles que sube el purr mientras se acaricia
@export var aumento_purr_caricia : float = 4.0
##segundos que tarda el purr en subir al acariciar
@export var duracion_subida_purr : float = 0.3
##segundos que el purr se mantiene fuerte despues de la caricia
@export var duracion_extra_purr : float = 5.0
##segundos que tarda el purr en volver a su volumen original
@export var duracion_bajada_purr : float = 1.5

@onready var layer_creditos: CanvasLayer = %LayerCreditos


var gato_actual : int = 0
var posicion_inicial : Vector2
var zoom_inicial : Vector2
var en_seleccion : bool = false
var tween : Tween
var tween_panel : Tween
var reproductor_purr : Node
var tween_purr : Tween
var tween_purr_caricia : Tween
var volumen_purr_base : float = 0.0
var dificultad_elegida : DificultadRun
var botones_dificultad : Array[Button] = []


func _ready() -> void:
	layer_creditos.hide()
	AudioManager.reproducir_musica(AudioManager.musica_menu)
	posicion_inicial = camara.global_position
	zoom_inicial = camara.zoom
	panel_info.visible = false
	boton_jugar.pressed.connect(abrir_seleccion)
	if boton_coleccion:
		boton_coleccion.pressed.connect(abrir_coleccion)
	boton_opciones.pressed.connect(opciones.show)
	boton_salir.pressed.connect(salir)
	boton_confirmar.pressed.connect(confirmar)
	boton_volver.pressed.connect(cerrar_seleccion)
	if guante_caricia:
		guante_caricia.caricia_iniciada.connect(al_iniciar_caricia)
		guante_caricia.caricia_terminada.connect(al_terminar_caricia)
	armar_panel_dificultad()
	mostrar_gato()


func armar_panel_dificultad() -> void:
	var boton : Button
	if not contenedor_dificultades:
		return
	for dificultad in dificultades:
		if not dificultad:
			continue
		boton = Button.new()
		boton.icon = dificultad.icono
		boton.expand_icon = true
		boton.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		boton.custom_minimum_size = Vector2(tamaño_boton_dificultad * dificultad.icono.get_width() / dificultad.icono.get_height(), tamaño_boton_dificultad) * dificultad.escala_icono if dificultad.icono else Vector2.ONE * tamaño_boton_dificultad
		boton.material = ShaderMaterial.new()
		boton.material.shader = shader_contorno
		boton.material.set_shader_parameter("grosor", grosor_borde_dificultad)
		for nombre_estilo in ["normal", "hover", "pressed", "focus"]:
			boton.add_theme_stylebox_override(nombre_estilo, StyleBoxEmpty.new())
		aplicar_borde_dificultad(boton, Color.TRANSPARENT)
		boton.pressed.connect(elegir_dificultad.bind(dificultad, boton))
		boton.mouse_entered.connect(mostrar_pergamino_dificultad.bind(dificultad))
		boton.mouse_exited.connect(Explicaciones.ocultar)
		contenedor_dificultades.add_child(boton)
		botones_dificultad.append(boton)
	if not botones_dificultad.is_empty():
		var indice_medio : int = mini(1, botones_dificultad.size() - 1)
		elegir_dificultad(dificultades[indice_medio], botones_dificultad[indice_medio])


func mostrar_pergamino_dificultad(dificultad : DificultadRun) -> void:
	Explicaciones.mostrar_texto(Progreso.placeholder_dificultad(dificultad).replace(":icono", ":texto/" + dificultad.nombre), dificultad.descripcion_para_mostrar(dificultad_referencia()))


func dificultad_referencia() -> DificultadRun:
	for dificultad in dificultades:
		if dificultad and dificultad.rango == 1:
			return dificultad
	return dificultades[0] if not dificultades.is_empty() else null


func elegir_dificultad(dificultad : DificultadRun, boton : Button) -> void:
	dificultad_elegida = dificultad
	for otro in botones_dificultad:
		aplicar_borde_dificultad(otro, Color.TRANSPARENT)
	aplicar_borde_dificultad(boton, dificultad.color_seleccion)


func aplicar_borde_dificultad(boton : Button, color : Color) -> void:
	boton.material.set_shader_parameter("color_borde", color)


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
	#layer_creditos.hide()
	en_seleccion = true
	iniciar_purr()
	habilitar_botones_menu(false)
	mover_camara(foco_seleccion.global_position, zoom_seleccion)
	tween.chain().tween_callback(mostrar_panel.bind(true))
	if guante_caricia:
		guante_caricia.activo = true


func cerrar_seleccion() -> void:
	#layer_creditos.show()
	en_seleccion = false
	terminar_orgulloso()
	if guante_caricia:
		guante_caricia.activo = false
	detener_purr()
	mostrar_panel(false)
	mover_camara(posicion_inicial, zoom_inicial)
	tween.chain().tween_callback(habilitar_botones_menu.bind(true))


func confirmar() -> void:
	detener_purr(Transicion.duracion)
	if not gatos.is_empty():
		Global.gato_elegido = gatos[gato_actual]
	GameManager.dificultad_actual = dificultad_elegida
	Transicion.cambiar_escena(escena_juego)


func iniciar_purr() -> void:
	var volumen_final : float
	reproductor_purr = AudioManager.reproducir_sfx(EfectoDeSonido.Tipo.MICHINKO_PURR)
	if not reproductor_purr:
		return
	if tween_purr:
		tween_purr.kill()
	volumen_final = reproductor_purr.volume_db
	volumen_purr_base = volumen_final
	reproductor_purr.volume_db = -40.0
	tween_purr = create_tween()
	tween_purr.tween_property(reproductor_purr, "volume_db", volumen_final, duracion_fade_purr)


func detener_purr(duracion : float = -1.0) -> void:
	var reproductor : Node = reproductor_purr
	reproductor_purr = null
	if duracion < 0.0:
		duracion = duracion_fade_purr
	if not is_instance_valid(reproductor) or not reproductor.playing:
		return
	if tween_purr_caricia:
		tween_purr_caricia.kill()
	if tween_purr:
		tween_purr.kill()
	tween_purr = reproductor.create_tween()
	tween_purr.tween_property(reproductor, "volume_db", -40.0, duracion)
	tween_purr.tween_callback(AudioManager.detener_sfx.bind(reproductor))


func al_iniciar_caricia() -> void:
	if gato_menu:
		gato_menu.orgulloso = true
	if not is_instance_valid(reproductor_purr):
		return
	if tween_purr_caricia:
		tween_purr_caricia.kill()
	tween_purr_caricia = create_tween()
	tween_purr_caricia.tween_property(reproductor_purr, "volume_db", volumen_purr_base + aumento_purr_caricia, duracion_subida_purr)


func al_terminar_caricia() -> void:
	if tween_purr_caricia:
		tween_purr_caricia.kill()
	tween_purr_caricia = create_tween()
	tween_purr_caricia.tween_interval(duracion_extra_purr)
	tween_purr_caricia.tween_callback(terminar_orgulloso)
	if is_instance_valid(reproductor_purr):
		tween_purr_caricia.tween_property(reproductor_purr, "volume_db", volumen_purr_base, duracion_bajada_purr)


func terminar_orgulloso() -> void:
	if gato_menu:
		gato_menu.orgulloso = false


func abrir_coleccion() -> void:
	Transicion.cambiar_escena(escena_coleccion)


func salir() -> void:
	get_tree().quit()


func mover_camara(posicion : Vector2, zoom : Vector2) -> void:
	AudioManager.reproducir_sfx(EfectoDeSonido.Tipo.WHOOSH_CAMARA)
	if tween:
		tween.kill()
	tween = create_tween().set_parallel().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(camara, "global_position", posicion, duracion_zoom)
	tween.tween_property(camara, "zoom", zoom, duracion_zoom)


func mostrar_panel(visible_panel : bool) -> void:
	if tween_panel:
		tween_panel.kill()
	tween_panel = create_tween().set_parallel()
	if visible_panel:
		panel_info.modulate.a = 0.0
		panel_info.visible = true
		tween_panel.tween_property(panel_info, "modulate:a", 1.0, duracion_fade_panel)
		if brillo_seleccion:
			brillo_seleccion.modulate.a = 0.0
			brillo_seleccion.visible = true
			tween_panel.tween_property(brillo_seleccion, "modulate:a", 1.0, duracion_fade_panel)
	else:
		tween_panel.tween_property(panel_info, "modulate:a", 0.0, duracion_fade_panel)
		if brillo_seleccion:
			tween_panel.tween_property(brillo_seleccion, "modulate:a", 0.0, duracion_fade_panel)
		tween_panel.chain().tween_callback(panel_info.hide)
		if brillo_seleccion:
			tween_panel.tween_callback(brillo_seleccion.hide)


func habilitar_botones_menu(habilitar : bool) -> void:
	for boton in get_children():
		if boton is BotonEstandarte:
			boton.mouse_filter = Control.MOUSE_FILTER_STOP if habilitar else Control.MOUSE_FILTER_IGNORE


func _on_boton_cerrar_creditos_pressed() -> void:
	layer_creditos.hide()


func _on_button_creditos_pressed() -> void:
		layer_creditos.show()
