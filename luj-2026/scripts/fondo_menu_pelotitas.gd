class_name FondoMenuPelotitas
extends Node2D

@export var escena_pelotita: PackedScene = preload("res://escenas/bola_de_pelos.tscn")
@export var tiempo_entre_pelotitas: float = 1.4
@export var max_pelotitas_simultaneas: int = 15
@export var ancho_pantalla: float = 1280.0
@export var limite_inferior_y: float = 850.0

var _temporizador: float = 0.0
var _contenedor_pelotitas: Node2D

func _ready() -> void:
	_contenedor_pelotitas = Node2D.new()
	_contenedor_pelotitas.name = "ContenedorPelotitas"
	add_child(_contenedor_pelotitas)
	
	# Generar un par de pelotitas iniciales para que el fondo no empiece vacío
	for i in range(4):
		_spawn_pelotita(randf_range(100.0, 400.0))

func _process(delta: float) -> void:
	_temporizador += delta
	if _temporizador >= tiempo_entre_pelotitas:
		_temporizador = 0.0
		if _contenedor_pelotitas.get_child_count() < max_pelotitas_simultaneas:
			_spawn_pelotita()
	
	# Limpieza de pelotitas que salieron de la pantalla
	for pelotita in _contenedor_pelotitas.get_children():
		if pelotita is Node2D and pelotita.global_position.y > limite_inferior_y:
			pelotita.queue_free()

func _spawn_pelotita(y_inicial: float = -50.0) -> void:
	if not escena_pelotita:
		return
	
	var instancia = escena_pelotita.instantiate()
	if instancia is RigidBody2D:
		instancia.position = Vector2(randf_range(80.0, ancho_pantalla - 80.0), y_inicial)
		_contenedor_pelotitas.add_child(instancia)
		
		# Silenciar o atenuar el audio en el fondo para que no sature el menú
		if instancia.has_node("AudioRebote"):
			var audio = instancia.get_node("AudioRebote") as AudioStreamPlayer
			if audio:
				audio.volume_db = -18.0
		
		# Impulso inicial aleatorio
		var impulso = Vector2(randf_range(-60.0, 60.0), randf_range(50.0, 150.0))
		instancia.apply_impulse(impulso)
		instancia.angular_velocity = randf_range(-3.0, 3.0)
