@icon("res://iconos_custom/cat.svg")
class_name Gato
extends RigidBody2D

signal escupir_bola

# ======== SPRITES que luego se borran ======
@export var sprite : Sprite2D
@export var imagen_normal : Texture2D #dsp cambiamos por animatedsprite ambos o solo este
@export var imagen_bolita : Texture2D

@export var disparador_pelotitas : DisparadorPelotita
@export var animation_player : AnimationPlayer
@export var game_manager : GameManager
@export var colision : CollisionShape2D

@export var fuerza_disparo : float = 1.0
##ovillos que puede romper el gato al ser lanzado
@export var impactos_maximos : int = 4
##segundos quieto tras el lanzamiento para considerarlo atascado
@export var tiempo_para_atascarse : float = 3.0
##velocidad por debajo de la cual el gato cuenta como quieto
@export var umbral_quieto : float = 10.0

# ======== MOVIMIENTO HORIZONTAL (RELIQUIA RASCADOR) ========
var movimiento_horizontal_habilitado : bool = false
@export var velocidad_movimiento_horizontal : float = 550.0
@export var limite_izquierdo : float = 80.0
@export var limite_derecho : float = 1200.0

var velocidad_inicial : Vector2
var posicion_mouse : Vector2
var listo_para_lanzar : bool
var _fue_lanzado : bool = false
var _finalizo_ronda : bool = false
var posicion_inicial : Vector2
var ovillos_rotos : int = 0
var tiempo_quieto : float = 0.0

func _ready() -> void:
	sprite.texture = imagen_bolita
	posicion_inicial = global_position
	if sprite:
		sprite.texture = imagen_normal
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
	body_entered.connect(al_chocar)


func al_chocar(body : Node) -> void:
	if not _fue_lanzado or _finalizo_ronda:
		return
	if body is Ovillo and ovillos_rotos < impactos_maximos:
		ovillos_rotos += 1
		body.recibir_impacto()

# ============ PROCESS / DETECCIÓN DE FIN DE NIVEL =============
func _process(delta : float) -> void:
	procesar_movimiento_horizontal(delta)
	actualizar_orientacion()


func procesar_movimiento_horizontal(delta : float) -> void:
	if not movimiento_horizontal_habilitado or not freeze:
		return
	
	var input_x : float = 0.0
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT) or Input.is_action_pressed("ui_left"):
		input_x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT) or Input.is_action_pressed("ui_right"):
		input_x += 1.0
	
	if input_x != 0.0:
		var ancho_viewport = get_viewport_rect().size.x
		var max_x = minf(limite_derecho, ancho_viewport - 80.0)
		global_position.x = clampf(global_position.x + input_x * velocidad_movimiento_horizontal * delta, limite_izquierdo, max_x)
		global_position.y = posicion_inicial.y
		
		# Actualizar vector de apuntado en tiempo real al moverse
		posicion_mouse = get_global_mouse_position()
		velocidad_inicial = (global_position - posicion_mouse) * fuerza_disparo


func actualizar_orientacion() -> void:
	if esta_apuntando():
		sprite.flip_h = get_global_mouse_position().x < global_position.x
		return
	if animation_player and animation_player.is_playing():
		return
	sprite.flip_h = false


func esta_apuntando() -> bool:
	if listo_para_lanzar:
		return true
	if not game_manager or game_manager.estado_actual != GameManager.EstadoDeJuego.LANZANDO_BOLAS:
		return false
	if animation_player and animation_player.is_playing():
		return false
	return get_tree().get_nodes_in_group("bolas_de_pelos").is_empty()


func _physics_process(delta: float) -> void:
	if _fue_lanzado and not _finalizo_ronda:
		# Si el gato cae por debajo de la pantalla o divisiones
		if global_position.y > get_viewport_rect().size.y + 100.0:
			_finalizo_ronda = true
			if game_manager:
				game_manager.finalizar_nivel()
			elif GameManager.instancia_actual:
				GameManager.instancia_actual.finalizar_nivel()
			return
		if linear_velocity.length() < umbral_quieto:
			tiempo_quieto += delta
			if tiempo_quieto >= tiempo_para_atascarse:
				atascarse()
		else:
			tiempo_quieto = 0.0


func atascarse() -> void:
	_finalizo_ronda = true
	if game_manager:
		game_manager.fallar_por_atasco()
	elif GameManager.instancia_actual:
		GameManager.instancia_actual.fallar_por_atasco()

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

# ============ FUNCIONES DE RELIQUIA RASCADOR ==============
func habilitar_movimiento_horizontal() -> void:
	movimiento_horizontal_habilitado = true
	print("Reliquia Rascador activa: Control horizontal habilitado (Usa A/D o Flechas Izq/Der)")

func habilitar_disparo_lateral() -> void:
	habilitar_movimiento_horizontal()

func reiniciar() -> void:
	if sprite:
		sprite.texture = imagen_normal
	freeze = true
	if colision:
		colision.set_deferred("disabled", true)
	listo_para_lanzar = false
	_fue_lanzado = false
	_finalizo_ronda = false
	velocidad_inicial = Vector2.ZERO
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	if posicion_inicial != Vector2.ZERO:
		call_deferred("teleportar_al_inicio")

func teleportar_al_inicio() -> void:
	PhysicsServer2D.body_set_state(get_rid(), PhysicsServer2D.BODY_STATE_TRANSFORM, Transform2D(0.0, posicion_inicial))
	PhysicsServer2D.body_set_state(get_rid(), PhysicsServer2D.BODY_STATE_LINEAR_VELOCITY, Vector2.ZERO)
	global_position = posicion_inicial
	rotation = 0.0

func preparar_lanzamiento() -> void:
	if sprite:
		sprite.texture = imagen_bolita
	call_deferred("habilitar_lanzamiento")

func habilitar_lanzamiento() -> void:
	listo_para_lanzar = true
	_fue_lanzado = false
	_finalizo_ronda = false
	print("GATO LANZAMIENTO LISTO")

func lanzar() -> void:
	freeze = false
	if colision:
		colision.set_deferred("disabled", false)
	apply_impulse(-velocidad_inicial)
	listo_para_lanzar = false
	_fue_lanzado = true
	ovillos_rotos = 0
	tiempo_quieto = 0.0

func preparar_bola() -> void:
	if animation_player:
		animation_player.stop()
		animation_player.play("escupir_bola")
