class_name Gato
extends RigidBody2D

signal escupir_bola

#======== SPRITES que luego se borran ======
@export var sprite : Sprite2D
@export var imagen_normal : Texture2D #dsp cambiamos por animatedsprite ambos o solo este
@export var imagen_bolita : Texture2D

@export var disparador_pelotitas : DisparadorPelotita
@export var game_manager : GameManager
@export var colision : CollisionShape2D

@export var fuerza_disparo : float = 1.0

var velocidad_inicial : Vector2
var posicion_mouse : Vector2
var listo_para_lanzar : bool
var fue_lanzado : bool = false
var finalizo_ronda : bool = false
var posicion_inicial : Vector2

func _ready() -> void:
	posicion_inicial = global_position
	#reiniciar() #lo comento pq era uno de los conflictos en git, revisar manana
	#sprite.texture = imagen_normal #deje a proposito directamente el sprite del gato bolita hasta q tengamos las otras
	freeze = true
	if colision:
		colision.set_deferred("disabled", true)
	listo_para_lanzar = false
	_fue_lanzado = false
	_finalizo_ronda = false
	
	if not game_manager and GameManager.instancia_actual:
		game_manager = GameManager.instancia_actual
	
	if game_manager:
		game_manager.gato_lanza_bola.connect(preparar_bola)
		game_manager.lanzar_gato.connect(preparar_lanzamiento)

# ============ PROCESS / DETECCIÓN DE FIN DE NIVEL ============
func _physics_process(delta: float) -> void:
	if fue_lanzado and not finalizo_ronda:
		# Si el gato cae por debajo de la pantalla o divisiones
		if global_position.y > 750.0:
			finalizo_ronda = true
			if game_manager:
				game_manager.finalizar_nivel()
			elif GameManager.instancia_actual:
				GameManager.instancia_actual.finalizar_nivel()

# ============ INPUT ==============
func _input(event: InputEvent) -> void:
	if not listo_para_lanzar:
		return
	
	if event is InputEventMouseMotion: # Se está moviendo el mouse
		posicion_mouse = get_global_mouse_position()
		velocidad_inicial = (global_position - posicion_mouse) * fuerza_disparo
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			lanzar()

#============ FUNCIONES ==============

func reiniciar() -> void:
	sprite.texture = imagen_normal
	freeze = true
	if colision:
		colision.set_deferred("disabled", true)
	listo_para_lanzar = false
	fue_lanzado = false
	finalizo_ronda = false
	velocidad_inicial = Vector2.ZERO
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	if posicion_inicial != Vector2.ZERO:
		call_deferred("teleportar_al_inicio")

func teleportar_al_inicio() -> void:
	PhysicsServer2D.body_set_state(get_rid(), PhysicsServer2D.BODY_STATE_TRANSFORM, Transform2D(0.0, posicion_inicial))
	PhysicsServer2D.body_set_state(get_rid(), PhysicsServer2D.BODY_STATE_LINEAR_VELOCITY, Vector2.ZERO)
	global_position = posicion_inicial


func preparar_lanzamiento():
	sprite.texture = imagen_bolita
	call_deferred("habilitar_lanzamiento")

func habilitar_lanzamiento() -> void:
	listo_para_lanzar = true
	fue_lanzado = false
	finalizo_ronda = false
	print("GATO LANZAMIENTO LISTO")

func lanzar() -> void:
	freeze = false
	if colision:
		colision.set_deferred("disabled", false)
	apply_impulse(-velocidad_inicial)
	listo_para_lanzar = false
	fue_lanzado = true

func preparar_bola() -> void:
	if disparador_pelotitas:
		disparador_pelotitas.escupir_bola()
