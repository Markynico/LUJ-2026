class_name Gato
extends RigidBody2D

signal escupir_bola

# ======== SPRITES que luego se borran ======
@export var sprite : Sprite2D
@export var imagen_normal : Texture2D #dsp cambiamos por animatedsprite ambos o solo este
@export var imagen_bolita : Texture2D

@export var disparador_pelotitas : DisparadorPelotita
@export var game_manager : GameManager
@export var colision : CollisionShape2D

@export var fuerza_disparo : float = 1.0

enum PosicionDisparo { SUPERIOR, LATERAL_IZQUIERDO, LATERAL_DERECHO }

var disparo_lateral_habilitado : bool = false
var posicion_actual : PosicionDisparo = PosicionDisparo.SUPERIOR
var pos_superior : Vector2
var pos_lateral_izq : Vector2 = Vector2(70, 300)
var pos_lateral_der : Vector2 = Vector2(1210, 300)

var velocidad_inicial : Vector2
var posicion_mouse : Vector2
var listo_para_lanzar : bool
var _fue_lanzado : bool = false
var _finalizo_ronda : bool = false
var posicion_inicial : Vector2

func _ready() -> void:
	#sprite.texture = imagen_normal #deje a proposito directamente el sprite del gato bolita hasta q tengamos las otras
	pos_superior = global_position
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

# ============ PROCESS / DETECCIÓN DE FIN DE NIVEL =============
func _physics_process(_delta: float) -> void:
	if _fue_lanzado and not _finalizo_ronda:
		# Si el gato cae por debajo de la pantalla o divisiones
		if global_position.y > get_viewport_rect().size.y + 100.0:
			_finalizo_ronda = true
			if game_manager:
				game_manager.finalizar_nivel()
			elif GameManager.instancia_actual:
				GameManager.instancia_actual.finalizar_nivel()

# ============ INPUT ==============
func _input(event: InputEvent) -> void:
	# Cambio de posición lateral con la reliquia Rascador
	if disparo_lateral_habilitado and freeze:
		if event is InputEventKey and event.pressed:
			if event.keycode == KEY_A or event.keycode == KEY_LEFT or event.keycode == KEY_Q:
				cambiar_posicion_disparo(PosicionDisparo.LATERAL_IZQUIERDO)
			elif event.keycode == KEY_D or event.keycode == KEY_RIGHT or event.keycode == KEY_E:
				cambiar_posicion_disparo(PosicionDisparo.LATERAL_DERECHO)
			elif event.keycode == KEY_W or event.keycode == KEY_UP or event.keycode == KEY_S:
				cambiar_posicion_disparo(PosicionDisparo.SUPERIOR)
		elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			var mouse_pos = get_global_mouse_position()
			if mouse_pos.x < 300:
				cambiar_posicion_disparo(PosicionDisparo.LATERAL_IZQUIERDO)
			elif mouse_pos.x > 980:
				cambiar_posicion_disparo(PosicionDisparo.LATERAL_DERECHO)
			else:
				cambiar_posicion_disparo(PosicionDisparo.SUPERIOR)

	if not listo_para_lanzar:
		return
	
	if event is InputEventMouseMotion: # Se está moviendo el mouse
		posicion_mouse = get_global_mouse_position()
		velocidad_inicial = (global_position - posicion_mouse) * fuerza_disparo
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			lanzar()

# ============ FUNCIONES DE RELIQUIA RASCADOR ==============
func habilitar_disparo_lateral() -> void:
	disparo_lateral_habilitado = true
	print("Reliquia Rascador activa: Disparo lateral disponible (Usa A/D, flechas o Clic Derecho)")

func cambiar_posicion_disparo(nueva_pos : PosicionDisparo) -> void:
	if not disparo_lateral_habilitado or not freeze:
		return
	posicion_actual = nueva_pos
	var target_pos = pos_superior
	match nueva_pos:
		PosicionDisparo.SUPERIOR:
			target_pos = pos_superior
		PosicionDisparo.LATERAL_IZQUIERDO:
			target_pos = pos_lateral_izq
		PosicionDisparo.LATERAL_DERECHO:
			target_pos = pos_lateral_der
	
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", target_pos, 0.25)

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

func preparar_bola() -> void:
	if disparador_pelotitas:
		disparador_pelotitas.escupir_bola()
