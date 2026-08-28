extends Node

const VOLUMEN_SILENCIO : float = -40.0

##todos los efectos de sonido del juego, configurados como recursos EfectoDeSonido
@export var efectos : Array[EfectoDeSonido] = []
##bus donde suenan los efectos
@export var bus_sfx : String = "SFX"
##bus donde suena la musica
@export var bus_musica : String = "Musica"
##duracion default del crossfade entre musicas
@export var duracion_fade : float = 1.5
##volumen inicial del bus de musica
@export_range(0.0, 1.0) var volumen_inicial_musica : float = 0.8
##volumen inicial del bus de sfx
@export_range(0.0, 1.0) var volumen_inicial_sfx : float = 0.8
@export_group("Musica")
##musica del menu principal
@export var musica_menu : AudioStream
##musica de los niveles y salas
@export var musica_juego : AudioStream
@export_group("")

var efectos_por_tipo : Dictionary = {}
var conteo_por_efecto : Dictionary = {}
var reproductor_activo : AudioStreamPlayer
var reproductor_inactivo : AudioStreamPlayer
var fade : Tween


func _ready() -> void:
	for efecto in efectos:
		efectos_por_tipo[efecto.tipo] = efecto
	reproductor_activo = crear_reproductor_musica()
	reproductor_inactivo = crear_reproductor_musica()
	cambiar_volumen_musica(volumen_inicial_musica)
	cambiar_volumen_sfx(volumen_inicial_sfx)


func crear_reproductor_musica() -> AudioStreamPlayer:
	var reproductor : AudioStreamPlayer = AudioStreamPlayer.new()
	reproductor.bus = bus_musica
	add_child(reproductor)
	return reproductor


func reproducir_sfx(tipo : EfectoDeSonido.Tipo, pitch_extra : float = 0.0) -> AudioStreamPlayer:
	var efecto : EfectoDeSonido = efectos_por_tipo.get(tipo)
	var reproductor : AudioStreamPlayer = AudioStreamPlayer.new()
	if not preparar_sfx(efecto, reproductor, pitch_extra):
		return null
	add_child(reproductor)
	reproductor.play()
	return reproductor


func reproducir_sfx_en(tipo : EfectoDeSonido.Tipo, posicion : Vector2, pitch_extra : float = 0.0) -> AudioStreamPlayer2D:
	var efecto : EfectoDeSonido = efectos_por_tipo.get(tipo)
	var reproductor : AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	if not preparar_sfx(efecto, reproductor, pitch_extra):
		return null
	add_child(reproductor)
	reproductor.global_position = posicion
	reproductor.play()
	return reproductor


func preparar_sfx(efecto : EfectoDeSonido, reproductor : Node, pitch_extra : float = 0.0) -> bool:
	var stream : AudioStream = efecto.stream_aleatorio() if efecto else null
	if not stream or conteo_por_efecto.get(efecto, 0) >= efecto.limite_simultaneos:
		reproductor.free()
		return false
	conteo_por_efecto[efecto] = conteo_por_efecto.get(efecto, 0) + 1
	reproductor.stream = stream
	reproductor.bus = bus_sfx
	reproductor.volume_db = efecto.volumen_db
	reproductor.pitch_scale = randf_range(efecto.pitch_minimo, efecto.pitch_maximo) + pitch_extra
	reproductor.finished.connect(al_terminar_sfx.bind(efecto, reproductor))
	return true


func detener_sfx(reproductor : Node) -> void:
	if is_instance_valid(reproductor) and reproductor.playing:
		reproductor.stop()
		reproductor.finished.emit()


func al_terminar_sfx(efecto : EfectoDeSonido, reproductor : Node) -> void:
	conteo_por_efecto[efecto] = max(0, conteo_por_efecto.get(efecto, 1) - 1)
	reproductor.queue_free()


func reproducir_musica(stream : AudioStream) -> void:
	var saliente : AudioStreamPlayer
	if not stream:
		return
	if reproductor_activo.stream == stream and reproductor_activo.playing:
		return
	saliente = reproductor_activo
	reproductor_activo = reproductor_inactivo
	reproductor_inactivo = saliente
	reproductor_activo.stream = stream
	reproductor_activo.volume_db = VOLUMEN_SILENCIO
	reproductor_activo.play()
	if fade:
		fade.kill()
	fade = create_tween().set_parallel()
	fade.tween_property(reproductor_activo, "volume_db", 0.0, duracion_fade)
	if saliente.playing:
		fade.tween_property(saliente, "volume_db", VOLUMEN_SILENCIO, duracion_fade)
		fade.chain().tween_callback(saliente.stop)


func detener_musica() -> void:
	if not reproductor_activo.playing:
		return
	if fade:
		fade.kill()
	fade = create_tween()
	fade.tween_property(reproductor_activo, "volume_db", VOLUMEN_SILENCIO, duracion_fade)
	fade.tween_callback(reproductor_activo.stop)


func cambiar_clip(nombre : String) -> void:
	var reproduccion : AudioStreamPlayback = reproductor_activo.get_stream_playback() if reproductor_activo.playing else null
	if reproduccion is AudioStreamPlaybackInteractive:
		reproduccion.switch_to_clip_by_name(nombre)


func cambiar_volumen_musica(volumen : float) -> void:
	cambiar_volumen_de_bus(bus_musica, volumen)


func cambiar_volumen_sfx(volumen : float) -> void:
	cambiar_volumen_de_bus(bus_sfx, volumen)


func cambiar_volumen_de_bus(bus : String, volumen : float) -> void:
	var indice : int = AudioServer.get_bus_index(bus)
	if indice < 0:
		return
	AudioServer.set_bus_volume_db(indice, linear_to_db(pow(volumen, 2.0)))
	AudioServer.set_bus_mute(indice, is_zero_approx(volumen))
