class_name Opciones
extends CanvasLayer

const RESOLUCIONES : Array[Vector2i] = [Vector2i(3840, 2160), Vector2i(2560, 1440), Vector2i(1920, 1080), Vector2i(1600, 900), Vector2i(1366, 768), Vector2i(1280, 720)]

@export var slider_musica : HSlider
@export var slider_efectos : HSlider
@export var opcion_ventana : OptionButton
@export var opcion_resolucion : OptionButton
@export var opcion_vsync : OptionButton
@export var boton_cerrar : Button
@export var boton_resetear : Button
@export var confirmacion_reset : ConfirmationDialog


func _ready() -> void:
	hide()
	slider_musica.value = volumen_de_bus(AudioManager.bus_musica)
	slider_efectos.value = volumen_de_bus(AudioManager.bus_sfx)
	opcion_ventana.select(indice_de_ventana())
	opcion_resolucion.select(RESOLUCIONES.find(DisplayServer.window_get_size()))
	opcion_vsync.select(DisplayServer.window_get_vsync_mode())
	actualizar_resolucion_habilitada()
	slider_musica.value_changed.connect(Ajustes.cambiar_volumen_musica)
	slider_efectos.value_changed.connect(Ajustes.cambiar_volumen_efectos)
	opcion_ventana.item_selected.connect(cambiar_ventana)
	opcion_resolucion.item_selected.connect(cambiar_resolucion)
	opcion_vsync.item_selected.connect(Ajustes.cambiar_vsync)
	boton_cerrar.pressed.connect(hide)
	if boton_resetear and confirmacion_reset:
		boton_resetear.pressed.connect(confirmacion_reset.popup_centered)
		confirmacion_reset.confirmed.connect(Progreso.resetear)


func volumen_de_bus(nombre_bus : String) -> float:
	var indice : int = AudioServer.get_bus_index(nombre_bus)
	return sqrt(db_to_linear(AudioServer.get_bus_volume_db(indice)))


func indice_de_ventana() -> int:
	match DisplayServer.window_get_mode():
		DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			return 0
		DisplayServer.WINDOW_MODE_FULLSCREEN:
			return 1
		_:
			return 2


func cambiar_ventana(indice : int) -> void:
	Ajustes.cambiar_ventana(indice)
	actualizar_resolucion_habilitada()


func cambiar_resolucion(indice : int) -> void:
	Ajustes.cambiar_resolucion(indice)


func actualizar_resolucion_habilitada() -> void:
	opcion_resolucion.disabled = DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_WINDOWED
