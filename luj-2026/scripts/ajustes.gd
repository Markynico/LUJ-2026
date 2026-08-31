extends Node

const RUTA_ARCHIVO : String = "user://opciones.cfg"
const SECCION : String = "opciones"

var volumen_musica : float = 1.0
var volumen_efectos : float = 1.0
var modo_ventana : int = 2
var indice_resolucion : int = -1
var modo_vsync : int = 1


func _ready() -> void:
	cargar()
	aplicar.call_deferred()


func cambiar_volumen_musica(volumen : float) -> void:
	volumen_musica = volumen
	AudioManager.cambiar_volumen_musica(volumen)
	guardar()


func cambiar_volumen_efectos(volumen : float) -> void:
	volumen_efectos = volumen
	AudioManager.cambiar_volumen_sfx(volumen)
	guardar()


func cambiar_ventana(indice : int) -> void:
	modo_ventana = indice
	match indice:
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		2:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
	guardar()


func cambiar_resolucion(indice : int) -> void:
	var pantalla : Vector2i = DisplayServer.screen_get_size()
	var posicion_pantalla : Vector2i = DisplayServer.screen_get_position()
	indice_resolucion = indice
	DisplayServer.window_set_size(Opciones.RESOLUCIONES[indice])
	DisplayServer.window_set_position(posicion_pantalla + (pantalla - Opciones.RESOLUCIONES[indice]) / 2)
	guardar()


func cambiar_vsync(indice : int) -> void:
	modo_vsync = indice
	match indice:
		0:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		1:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		2:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ADAPTIVE)
	guardar()


func aplicar() -> void:
	AudioManager.cambiar_volumen_musica(volumen_musica)
	AudioManager.cambiar_volumen_sfx(volumen_efectos)
	cambiar_vsync(modo_vsync)
	cambiar_ventana(modo_ventana)
	if modo_ventana == 2 and indice_resolucion >= 0:
		cambiar_resolucion(indice_resolucion)


func guardar() -> void:
	var archivo : ConfigFile = ConfigFile.new()
	archivo.set_value(SECCION, "volumen_musica", volumen_musica)
	archivo.set_value(SECCION, "volumen_efectos", volumen_efectos)
	archivo.set_value(SECCION, "modo_ventana", modo_ventana)
	archivo.set_value(SECCION, "indice_resolucion", indice_resolucion)
	archivo.set_value(SECCION, "modo_vsync", modo_vsync)
	archivo.save(RUTA_ARCHIVO)


func cargar() -> void:
	var archivo : ConfigFile = ConfigFile.new()
	if archivo.load(RUTA_ARCHIVO) != OK:
		return
	volumen_musica = archivo.get_value(SECCION, "volumen_musica", 1.0)
	volumen_efectos = archivo.get_value(SECCION, "volumen_efectos", 1.0)
	modo_ventana = archivo.get_value(SECCION, "modo_ventana", 2)
	indice_resolucion = archivo.get_value(SECCION, "indice_resolucion", -1)
	modo_vsync = archivo.get_value(SECCION, "modo_vsync", 1)
