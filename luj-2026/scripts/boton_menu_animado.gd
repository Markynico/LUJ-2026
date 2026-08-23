class_name BotonMenuAnimado
extends Button

@export var sonido_click: AudioStream = preload("res://sonidos/sonido_pop.wav")
@export var escala_hover: Vector2 = Vector2(1.06, 1.06)
@export var escala_press: Vector2 = Vector2(0.92, 0.92)
@export var duracion_animacion: float = 0.12

var _tween: Tween
var _audio_player: AudioStreamPlayer

func _ready() -> void:
	# Ajustar el punto de pivote al centro del botón para que escale desde el medio
	pivot_offset = size / 2.0
	resized.connect(_on_resized)
	
	# Configurar reproductor de audio
	_audio_player = AudioStreamPlayer.new()
	_audio_player.stream = sonido_click
	_audio_player.volume_db = -4.0
	add_child(_audio_player)
	
	# Conectar señales de interacción
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)

func _on_resized() -> void:
	pivot_offset = size / 2.0

func _animar_escala(target_scale: Vector2, trans: Tween.TransitionType = Tween.TRANS_SINE) -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	_tween = create_tween().set_parallel(true).set_trans(trans).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "scale", target_scale, duracion_animacion)

func _on_mouse_entered() -> void:
	if not is_pressed():
		_animar_escala(escala_hover, Tween.TRANS_BACK)

func _on_mouse_exited() -> void:
	if not is_pressed():
		_animar_escala(Vector2.ONE)

func _on_button_down() -> void:
	_animar_escala(escala_press, Tween.TRANS_QUAD)
	if _audio_player and _audio_player.stream:
		_audio_player.pitch_scale = randf_range(0.95, 1.1)
		_audio_player.play()

func _on_button_up() -> void:
	if is_hovered():
		_animar_escala(escala_hover, Tween.TRANS_BACK)
	else:
		_animar_escala(Vector2.ONE, Tween.TRANS_BACK)
