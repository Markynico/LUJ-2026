class_name MichinkoOvillo
extends AnimatedSprite2D

##segundos minimos de espera entre animaciones
@export var espera_minima : float = 3.0
##segundos maximos de espera entre animaciones
@export var espera_maxima : float = 10.0


func _ready() -> void:
	animation_finished.connect(descansar)
	descansar()


func descansar() -> void:
	stop()
	frame = 0
	get_tree().create_timer(randf_range(espera_minima, espera_maxima)).timeout.connect(play.bind("default"))
