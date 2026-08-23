class_name MenuPrincipal
extends Control

@export var escena_juego: String = "res://escenas/prueba_escena.tscn"

@onready var boton_play: Button = %BotonPlay
@onready var boton_opciones: Button = %BotonOpciones
@onready var boton_creditos: Button = %BotonCreditos
@onready var boton_salir: Button = %BotonSalir

@onready var panel_opciones: PanelContainer = %PanelOpciones
@onready var panel_creditos: PanelContainer = %PanelCreditos
@onready var boton_cerrar_opciones: Button = %BotonCerrarOpciones
@onready var boton_cerrar_creditos: Button = %BotonCerrarCreditos

@onready var check_pantalla_completa: CheckBox = %CheckPantallaCompleta
@onready var slider_volumen: HSlider = %SliderVolumen
@onready var contenedor_titulo: Control = %ContenedorTitulo

var _tween_titulo: Tween

func _ready() -> void:
	# Ocultar modales al iniciar
	panel_opciones.visible = false
	panel_creditos.visible = false
	
	# Conectar botones principales
	boton_play.pressed.connect(_on_play_pressed)
	boton_opciones.pressed.connect(_on_opciones_pressed)
	boton_creditos.pressed.connect(_on_creditos_pressed)
	boton_salir.pressed.connect(_on_salir_pressed)
	
	# Conectar botones de cierre de modales
	boton_cerrar_opciones.pressed.connect(func(): _cerrar_modal(panel_opciones))
	boton_cerrar_creditos.pressed.connect(func(): _cerrar_modal(panel_creditos))
	
	# Configurar opciones de audio y pantalla
	_configurar_opciones()
	
	# Iniciar animación suave flotante del título
	_iniciar_animacion_titulo()

func _iniciar_animacion_titulo() -> void:
	if not contenedor_titulo:
		return
	var pos_original = contenedor_titulo.position.y
	_tween_titulo = create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tween_titulo.tween_property(contenedor_titulo, "position:y", pos_original - 10.0, 1.8)
	_tween_titulo.tween_property(contenedor_titulo, "position:y", pos_original + 10.0, 1.8)

func _configurar_opciones() -> void:
	if check_pantalla_completa:
		check_pantalla_completa.button_pressed = (DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN)
		check_pantalla_completa.toggled.connect(_on_pantalla_completa_toggled)
	
	if slider_volumen:
		slider_volumen.value = db_to_linear(AudioServer.get_bus_volume_db(0)) * 100.0
		slider_volumen.value_changed.connect(_on_volumen_changed)

func _on_play_pressed() -> void:
	# Pequeño retardo o transición antes de cambiar de escena
	var tween = create_tween()
	var fade_rect = ColorRect.new()
	fade_rect.color = Color(0, 0, 0, 0)
	fade_rect.set_anchors_preset(PRESET_FULL_RECT)
	fade_rect.mouse_filter = MOUSE_FILTER_STOP
	add_child(fade_rect)
	
	tween.tween_property(fade_rect, "color:a", 1.0, 0.3)
	tween.finished.connect(func():
		if ResourceLoader.exists(escena_juego):
			get_tree().change_scene_to_file(escena_juego)
		else:
			print("Escena de juego no encontrada: ", escena_juego)
	)

func _on_opciones_pressed() -> void:
	_abrir_modal(panel_opciones)

func _on_creditos_pressed() -> void:
	_abrir_modal(panel_creditos)

func _on_salir_pressed() -> void:
	get_tree().quit()

func _abrir_modal(panel: Control) -> void:
	panel.visible = true
	panel.scale = Vector2(0.85, 0.85)
	panel.modulate.a = 0.0
	panel.pivot_offset = panel.size / 2.0
	
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(panel, "scale", Vector2.ONE, 0.25)
	tween.tween_property(panel, "modulate:a", 1.0, 0.2)

func _cerrar_modal(panel: Control) -> void:
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(panel, "scale", Vector2(0.85, 0.85), 0.15)
	tween.tween_property(panel, "modulate:a", 0.0, 0.15)
	tween.finished.connect(func(): panel.visible = false)

func _on_pantalla_completa_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_volumen_changed(value: float) -> void:
	var bus_index = AudioServer.get_bus_index("Master")
	if bus_index != -1:
		var linear = value / 100.0
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(linear))
