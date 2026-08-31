extends CanvasLayer

##segundos totales de la transicion, mitad fade a negro y mitad vuelta
@export var duracion : float = 2.0
##frecuencia del low pass cuando la pantalla esta en negro
@export var frecuencia_cerrada : float = 400.0
##frecuencia del low pass con el filtro abierto
@export var frecuencia_abierta : float = 20500.0
##frecuencia del low pass suave para la musica en menus
@export var frecuencia_musica_filtrada : float = 2000.0
@export var fade : ColorRect

var indice_filtro : int = -1
var indice_filtro_musica : int = -1
var bus_musica : int = -1
var ocupado : bool = false
var tween : Tween
var tween_musica : Tween


func _ready() -> void:
	var filtro : AudioEffectLowPassFilter = AudioEffectLowPassFilter.new()
	fade.modulate.a = 0.0
	fade.hide()
	filtro.cutoff_hz = frecuencia_abierta
	AudioServer.add_bus_effect(0, filtro)
	indice_filtro = AudioServer.get_bus_effect_count(0) - 1
	AudioServer.set_bus_effect_enabled(0, indice_filtro, false)
	bus_musica = AudioServer.get_bus_index("Musica")
	if bus_musica >= 0:
		var filtro_musica : AudioEffectLowPassFilter = AudioEffectLowPassFilter.new()
		filtro_musica.cutoff_hz = frecuencia_abierta
		AudioServer.add_bus_effect(bus_musica, filtro_musica)
		indice_filtro_musica = AudioServer.get_bus_effect_count(bus_musica) - 1
		AudioServer.set_bus_effect_enabled(bus_musica, indice_filtro_musica, false)


func filtrar_musica(activar : bool) -> void:
	var filtro : AudioEffectLowPassFilter
	var destino : float = frecuencia_musica_filtrada if activar else frecuencia_abierta
	if indice_filtro_musica < 0:
		return
	filtro = AudioServer.get_bus_effect(bus_musica, indice_filtro_musica)
	if activar:
		AudioServer.set_bus_effect_enabled(bus_musica, indice_filtro_musica, true)
	if tween_musica:
		tween_musica.kill()
	tween_musica = create_tween()
	tween_musica.tween_property(filtro, "cutoff_hz", destino, 0.5)
	if not activar:
		tween_musica.tween_callback(AudioServer.set_bus_effect_enabled.bind(bus_musica, indice_filtro_musica, false))


func transicionar(accion : Callable) -> void:
	var mitad : float = duracion * 0.5
	var inicio : float = tomar_frecuencia_actual()
	if ocupado:
		accion.call()
		return
	ocupado = true
	fade.modulate.a = 0.0
	fade.show()
	poner_frecuencia(inicio)
	AudioServer.set_bus_effect_enabled(0, indice_filtro, true)
	tween = create_tween()
	tween.tween_property(fade, "modulate:a", 1.0, mitad)
	tween.parallel().tween_method(poner_frecuencia, inicio, frecuencia_cerrada, mitad)
	tween.tween_callback(accion)
	tween.tween_property(fade, "modulate:a", 0.0, mitad)
	tween.parallel().tween_method(poner_frecuencia, frecuencia_cerrada, frecuencia_abierta, mitad)
	tween.tween_callback(terminar)


func cambiar_escena(ruta : String) -> void:
	transicionar(cambiar_escena_ahora.bind(ruta))


func cambiar_escena_ahora(ruta : String) -> void:
	get_tree().change_scene_to_file(ruta)


func tomar_frecuencia_actual() -> float:
	var filtro : AudioEffectLowPassFilter
	if indice_filtro_musica < 0 or not AudioServer.is_bus_effect_enabled(bus_musica, indice_filtro_musica):
		return frecuencia_abierta
	filtro = AudioServer.get_bus_effect(bus_musica, indice_filtro_musica)
	if tween_musica:
		tween_musica.kill()
	AudioServer.set_bus_effect_enabled(bus_musica, indice_filtro_musica, false)
	return filtro.cutoff_hz


func poner_frecuencia(frecuencia : float) -> void:
	var filtro : AudioEffectLowPassFilter = AudioServer.get_bus_effect(0, indice_filtro)
	filtro.cutoff_hz = frecuencia


func terminar() -> void:
	fade.hide()
	AudioServer.set_bus_effect_enabled(0, indice_filtro, false)
	ocupado = false
