class_name Gato
extends RigidBody2D

signal escupir_bola

#======== SPRITES que luego se borran ======
@export var sprite : Sprite2D
@export var imagen_normal : Texture2D
@export var imagen_bolita : Texture2D

@export var disparador_pelotitas : DisparadorPelotita
@export var game_manager : GameManager
@export var colision : CollisionShape2D

@export var fuerza_disparo : float = 1.0

var velocidad_inicial : Vector2
var posicion_mouse : Vector2
var listo_para_lanzar : bool

func _ready() -> void:
	sprite.texture = imagen_normal
	freeze = true
	colision.set_deferred("disabled", true)
	listo_para_lanzar = false
	game_manager.gato_lanza_bola.connect(preparar_bola)
	game_manager.lanzar_gato.connect(preparar_lanzamiento)

#============ INPUT ==============
func _input(event: InputEvent) -> void:
	if not listo_para_lanzar:
		return
	
	if event is InputEventMouseMotion: #Se esta moviendo el mouse
		posicion_mouse = get_global_mouse_position()
		velocidad_inicial = (global_position - posicion_mouse) * fuerza_disparo #no lo normalizo para q justamente dispare mas fuerte si el mouse esta lejos
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			lanzar()

#============ FUNCIONES ==============

func preparar_lanzamiento():
	sprite.texture = imagen_bolita
	call_deferred("habilitar_lanzamiento")


func habilitar_lanzamiento():
	listo_para_lanzar = true
	print("GATO LANZAMIENTO LISTO")

func lanzar():
	freeze = false
	colision.set_deferred("disabled", false)
	apply_impulse(-velocidad_inicial)
	
	listo_para_lanzar = false


func preparar_bola():
	disparador_pelotitas.escupir_bola()
