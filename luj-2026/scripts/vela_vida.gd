@tool
class_name VelaVida
extends AnimatedSprite2D

enum Estado { ENCENDIDA, APAGANDOSE, MUERTA }

##segundos que dura la animacion de apagandose antes de pasar a muerta
@export var duracion_apagandose : float = 10.0
##segundos del fade out cuando la vela pierde su slot
@export var duracion_fade : float = 2.0
##desplazamiento del sprite solo en el estado muerta
@export var offset_muerta : Vector2 = Vector2.ZERO:
	set(valor):
		offset_muerta = valor
		aplicar_estado()
##muestra la vela muerta en el editor para ubicar el offset
@export var vista_previa_muerta : bool = false:
	set(valor):
		vista_previa_muerta = valor
		if Engine.is_editor_hint():
			estado = Estado.MUERTA if vista_previa_muerta else Estado.APAGANDOSE
			aplicar_estado()

@export_group("NODOS")
@export var luz : PointLight2D

var estado : Estado = Estado.ENCENDIDA
var timer_muerte : SceneTreeTimer


func _ready() -> void:
	aplicar_estado()


func encender() -> void:
	if estado == Estado.ENCENDIDA:
		return
	estado = Estado.ENCENDIDA
	timer_muerte = null
	aplicar_estado()


func apagar() -> void:
	if estado != Estado.ENCENDIDA:
		return
	estado = Estado.APAGANDOSE
	aplicar_estado()
	timer_muerte = get_tree().create_timer(duracion_apagandose)
	timer_muerte.timeout.connect(morir.bind(timer_muerte))


func matar() -> void:
	if estado == Estado.MUERTA:
		return
	estado = Estado.MUERTA
	timer_muerte = null
	aplicar_estado()


func morir(timer : SceneTreeTimer) -> void:
	if timer != timer_muerte or estado != Estado.APAGANDOSE:
		return
	estado = Estado.MUERTA
	aplicar_estado()


func desaparecer() -> void:
	var tween : Tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, duracion_fade)
	tween.tween_callback(queue_free)


func aplicar_estado() -> void:
	if luz:
		luz.enabled = estado == Estado.ENCENDIDA
	if not sprite_frames:
		return
	match estado:
		Estado.ENCENDIDA:
			offset = Vector2.ZERO
			play("encendida")
			set_frame_and_progress(randi() % sprite_frames.get_frame_count("encendida"), randf())
		Estado.APAGANDOSE:
			offset = Vector2.ZERO
			play("apagandose")
		Estado.MUERTA:
			offset = offset_muerta
			play("muerta")
