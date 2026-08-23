class_name ReproductorMusica
extends PanelContainer

@export var lista_canciones: Array[AudioStream] = []
@export var nombres_canciones: Array[String] = [
	"Tema Principal - Michi Adventure",
	"Nivel 1 - TEma copado",
	"Nivel 2 - algo epicardo",
	"Bonus - BOCA BOCA BOCA"
]
@export var autoplay: bool = false

var indice_actual: int = 0
var _esta_reproduciendo: bool = false
var _arrastrando_slider: bool = false

@onready var label_titulo: Label = %LabelTituloCancion
@onready var label_tiempo: Label = %LabelTiempo
@onready var slider_progreso: HSlider = %SliderProgreso
@onready var boton_anterior: Button = %BotonAnterior
@onready var boton_play_pause: Button = %BotonPlayPause
@onready var boton_siguiente: Button = %BotonSiguiente
@onready var audio_player: AudioStreamPlayer = %AudioPlayer

func _ready() -> void:
	# Conectar botones
	boton_anterior.pressed.connect(_on_anterior_pressed)
	boton_play_pause.pressed.connect(_on_play_pause_pressed)
	boton_siguiente.pressed.connect(_on_siguiente_pressed)
	
	# Control del slider
	slider_progreso.drag_started.connect(func(): _arrastrando_slider = true)
	slider_progreso.drag_ended.connect(_on_slider_drag_ended)
	
	# Evento al terminar la canción
	audio_player.finished.connect(_on_cancion_terminada)
	
	# Inicializar primera canción
	_actualizar_info_pista()
	
	if autoplay and lista_canciones.size() > 0 and lista_canciones[0] != null:
		_reproducir_cancion()

func _process(_delta: float) -> void:
	if _esta_reproduciendo and audio_player.playing and not _arrastrando_slider:
		var pos_actual = audio_player.get_playback_position()
		var duracion = _obtener_duracion_actual()
		
		if duracion > 0.0:
			slider_progreso.max_value = duracion
			slider_progreso.value = pos_actual
			label_tiempo.text = "%s / %s" % [_formatear_tiempo(pos_actual), _formatear_tiempo(duracion)]
		else:
			slider_progreso.value = 0.0
			label_tiempo.text = "%s / --:--" % [_formatear_tiempo(pos_actual)]

func _actualizar_info_pista() -> void:
	var total_pistas = max(lista_canciones.size(), nombres_canciones.size(), 1)
	var nombre = "Pista %d" % (indice_actual + 1)
	
	if indice_actual < nombres_canciones.size() and not nombres_canciones[indice_actual].is_empty():
		nombre = nombres_canciones[indice_actual]
	elif indice_actual < lista_canciones.size() and lista_canciones[indice_actual] != null:
		nombre = lista_canciones[indice_actual].resource_path.get_file().get_basename()
	
	label_titulo.text = "♫  [%d/%d] %s" % [indice_actual + 1, total_pistas, nombre]
	
	# Actualizar duración en el label
	var duracion = _obtener_duracion_actual()
	if duracion > 0.0:
		slider_progreso.max_value = duracion
		label_tiempo.text = "00:00 / %s" % _formatear_tiempo(duracion)
	else:
		slider_progreso.max_value = 100.0
		label_tiempo.text = "00:00 / --:--"
	
	slider_progreso.value = 0.0

func _obtener_duracion_actual() -> float:
	if indice_actual < lista_canciones.size() and lista_canciones[indice_actual] != null:
		return lista_canciones[indice_actual].get_length()
	return 0.0

func _reproducir_cancion() -> void:
	if indice_actual < lista_canciones.size() and lista_canciones[indice_actual] != null:
		audio_player.stream = lista_canciones[indice_actual]
		audio_player.play()
		_esta_reproduciendo = true
		boton_play_pause.text = "⏸"
	else:
		# Si no hay archivo de audio cargado aún en esta ranura
		_esta_reproduciendo = true
		boton_play_pause.text = "⏸"
		print("Reproduciendo (placeholder sin stream de audio asignado): ", nombres_canciones[indice_actual] if indice_actual < nombres_canciones.size() else "Pista")

func _pausar_cancion() -> void:
	if audio_player.playing:
		audio_player.stop()
	_esta_reproduciendo = false
	boton_play_pause.text = "▶"

func _on_play_pause_pressed() -> void:
	if _esta_reproduciendo:
		_pausar_cancion()
	else:
		_reproducir_cancion()

func _on_anterior_pressed() -> void:
	var total = max(lista_canciones.size(), nombres_canciones.size(), 1)
	indice_actual = (indice_actual - 1 + total) % total
	_actualizar_info_pista()
	if _esta_reproduciendo:
		_reproducir_cancion()

func _on_siguiente_pressed() -> void:
	var total = max(lista_canciones.size(), nombres_canciones.size(), 1)
	indice_actual = (indice_actual + 1) % total
	_actualizar_info_pista()
	if _esta_reproduciendo:
		_reproducir_cancion()

func _on_cancion_terminada() -> void:
	_on_siguiente_pressed()

func _on_slider_drag_ended(value_changed: bool) -> void:
	_arrastrando_slider = false
	if value_changed and _esta_reproduciendo and audio_player.stream != null:
		audio_player.seek(slider_progreso.value)

func _formatear_tiempo(segundos: float) -> String:
	var mins = int(segundos) / 60
	var segs = int(segundos) % 60
	return "%02d:%02d" % [mins, segs]
