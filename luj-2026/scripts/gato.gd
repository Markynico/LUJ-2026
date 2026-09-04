@tool
@icon("res://iconos_custom/cat.svg")
class_name Gato
extends RigidBody2D

signal escupir_bola

##gato de adorno: sin disparador ni trayectoria, para el menu
@export var decorativo : bool = false
##fija el estado orgulloso (sprite + particulas) apenas arranca, tambien en el editor
@export var orgulloso : bool = false:
	set(valor):
		orgulloso = valor
		if is_inside_tree():
			aplicar_orgulloso()
##datos del gato que se usan si no hay uno elegido en el menu; en el editor sirve de preview
@export var datos : DatosGato:
	set(valor):
		datos = valor
		if Engine.is_editor_hint() and is_inside_tree():
			aplicar_datos(valor)
##segundos quieto tras el lanzamiento para considerarlo atascado
@export var tiempo_para_atascarse : float = 3.0
##velocidad por debajo de la cual el gato cuenta como quieto
@export var umbral_quieto : float = 10.0

@export_group("Sprites")
##z del sprite mientras el gato vuela lanzado, para taparse la baranda
@export var z_lanzado : int = 20

@export_group("Blink")
##segundos minimos entre blinks
@export var intervalo_blink_minimo : float = 3.0
##segundos maximos entre blinks
@export var intervalo_blink_maximo : float = 8.0

@export_group("Movimiento horizontal (reliquia Rascador)")
@export var velocidad_movimiento_horizontal : float = 550.0
@export var limite_izquierdo : float = 80.0
@export var limite_derecho : float = 1200.0

@export_group("Nodos")
@export var sprite : Sprite2D
@export var colision : CollisionShape2D
@export var disparador_pelotitas : DisparadorPelotita
@export var animation_player : AnimationPlayer
@export var timer_blink : Timer
@export var particulas_orgulloso : CPUParticles2D
@export var game_manager : GameManager

var movimiento_horizontal_habilitado : bool = false
var fuerza_disparo : float = 1.0
var impactos_maximos : int = 4
var imagen_normal : Texture2D
var imagen_bolita : Texture2D
var imagen_orgulloso : Texture2D
var escala_normal : float = 0.32
var escala_bolita : float = 0.26

var velocidad_inicial : Vector2
var velocidad_antes_del_paso : Vector2 = Vector2.ZERO
var posicion_mouse : Vector2
var listo_para_lanzar : bool
var _fue_lanzado : bool = false
var _finalizo_ronda : bool = false
var posicion_inicial : Vector2
var ovillos_rotos : int = 0
var tiempo_quieto : float = 0.0

func _enter_tree() -> void:
	if Engine.is_editor_hint():
		aplicar_datos(datos)
		return
	aplicar_datos(Global.gato_elegido if Global.gato_elegido else datos)


func _ready() -> void:
	if Engine.is_editor_hint():
		aplicar_orgulloso()
		return
	posicion_inicial = global_position
	aplicar_orgulloso()
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
	if animation_player:
		animation_player.animation_finished.connect(al_terminar_animacion)
	if timer_blink:
		timer_blink.timeout.connect(al_sonar_timer_blink)
		programar_blink()
	if decorativo and disparador_pelotitas:
		disparador_pelotitas.hide()
		disparador_pelotitas.process_mode = Node.PROCESS_MODE_DISABLED


func al_terminar_animacion(nombre : StringName) -> void:
	if listo_para_lanzar:
		return
	if nombre == &"escupir_bola":
		animation_player.speed_scale = 1.0
	if nombre == &"escupir_bola" or nombre == &"blink":
		if sprite:
			sprite.texture = imagen_normal
		emitir_particulas(false)
		programar_blink()


func programar_blink() -> void:
	if timer_blink:
		timer_blink.start(randf_range(intervalo_blink_minimo, intervalo_blink_maximo))


func al_sonar_timer_blink() -> void:
	if puede_blinkear():
		animation_player.play("blink")
	else:
		programar_blink()


func sonar_blink() -> void:
	AudioManager.reproducir_sfx(EfectoDeSonido.Tipo.MICHINKO_BLINK)


func puede_blinkear() -> bool:
	if listo_para_lanzar or _fue_lanzado or orgulloso:
		return false
	if not animation_player or animation_player.is_playing():
		return false
	return true


func al_chocar(body : Node) -> void:
	if not _fue_lanzado or _finalizo_ronda:
		return
	if body is Ovillo and ovillos_rotos < impactos_maximos:
		var resultado : ResultadoImpacto = body.simular_impacto(null)
		if resultado.cuenta_para_el_gato:
			ovillos_rotos += 1
		if resultado.atravesar:
			add_collision_exception_with(body)
			linear_velocity = velocidad_antes_del_paso
		body.recibir_impacto()

# ============ PROCESS / DETECCIÓN DE FIN DE NIVEL =============
func _process(delta : float) -> void:
	if Engine.is_editor_hint():
		return
	procesar_movimiento_horizontal(delta)
	actualizar_orientacion()
	if listo_para_lanzar:
		posicion_mouse = get_global_mouse_position()
		velocidad_inicial = (global_position - posicion_mouse) * fuerza_disparo


func procesar_movimiento_horizontal(delta : float) -> void:
	if not movimiento_horizontal_habilitado or not freeze:
		return
	if esta_escupiendo():
		return
	
	var input_x : float = 0.0
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT) or Input.is_action_pressed("ui_left"):
		input_x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT) or Input.is_action_pressed("ui_right"):
		input_x += 1.0
	
	if input_x != 0.0:
		move_and_collide(Vector2(input_x * velocidad_movimiento_horizontal * delta, 0.0))
		global_position.y = posicion_inicial.y
		posicion_mouse = get_global_mouse_position()
		velocidad_inicial = (global_position - posicion_mouse) * fuerza_disparo


func actualizar_orientacion() -> void:
	if esta_apuntando():
		sprite.flip_h = get_global_mouse_position().x < global_position.x
		espejar_particulas(sprite.flip_h)
		return
	if esta_escupiendo():
		return
	sprite.flip_h = false
	espejar_particulas(false)


func esta_escupiendo() -> bool:
	if not animation_player:
		return false
	return animation_player.current_animation == "escupir_bola" and animation_player.is_playing()


func esta_apuntando() -> bool:
	if listo_para_lanzar:
		return true
	if not game_manager or game_manager.estado_actual != GameManager.EstadoDeJuego.LANZANDO_BOLAS:
		return false
	if esta_escupiendo():
		return false
	return get_tree().get_nodes_in_group("bolas_de_pelos").is_empty()


func _physics_process(delta: float) -> void:
	velocidad_antes_del_paso = linear_velocity
	if Engine.is_editor_hint():
		return
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
func _unhandled_input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	if not listo_para_lanzar:
		return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			lanzar()

# ============ FUNCIONES DE RELIQUIA RASCADOR ==============
func habilitar_movimiento_horizontal() -> void:
	movimiento_horizontal_habilitado = true
	if colision:
		colision.set_deferred("disabled", false)
	print("Reliquia Rascador activa: Control horizontal habilitado (Usa A/D o Flechas Izq/Der)")

func habilitar_disparo_lateral() -> void:
	habilitar_movimiento_horizontal()

func reiniciar() -> void:
	if sprite:
		sprite.texture = imagen_normal
		sprite.scale = Vector2.ONE * escala_normal
		sprite.z_index = 0
	emitir_particulas(false)
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
	if animation_player:
		animation_player.stop()
	if sprite:
		sprite.texture = imagen_orgulloso
		sprite.scale = Vector2.ONE * escala_normal
	emitir_particulas(true)
	call_deferred("habilitar_lanzamiento")

func habilitar_lanzamiento() -> void:
	listo_para_lanzar = true
	_fue_lanzado = false
	_finalizo_ronda = false
	print("GATO LANZAMIENTO LISTO")

func lanzar() -> void:
	if sprite:
		sprite.texture = imagen_bolita
		sprite.scale = Vector2.ONE * escala_bolita
		sprite.z_index = z_lanzado
	emitir_particulas(false)
	freeze = false
	if colision:
		colision.set_deferred("disabled", false)
	apply_impulse(-velocidad_inicial)
	listo_para_lanzar = false
	_fue_lanzado = true
	ovillos_rotos = 0
	tiempo_quieto = 0.0

func preparar_bola() -> void:
	if not animation_player:
		return
	animation_player.stop()
	animation_player.speed_scale = ReliquiasManager.multiplicador_velocidad_escupida()
	animation_player.play("escupir_bola")
	if ReliquiasManager.escupida_instantanea():
		animation_player.seek(tiempo_de_escupida("escupir_bola") + 0.01, true)
		disparador_pelotitas.escupir_bola()


func tiempo_de_escupida(nombre : StringName) -> float:
	var animacion : Animation = animation_player.get_animation(nombre)
	if not animacion:
		return 0.0
	for pista in animacion.get_track_count():
		if animacion.track_get_type(pista) == Animation.TYPE_METHOD and animacion.track_get_key_count(pista) > 0:
			return animacion.track_get_key_time(pista, 0)
	return 0.0


func emitir_particulas(encendido : bool) -> void:
	if particulas_orgulloso:
		particulas_orgulloso.emitting = encendido


func espejar_particulas(espejado : bool) -> void:
	if not particulas_orgulloso:
		return
	particulas_orgulloso.position.x = -absf(particulas_orgulloso.position.x) if espejado else absf(particulas_orgulloso.position.x)
	particulas_orgulloso.scale.x = -1.0 if espejado else 1.0


func aplicar_datos(nuevos : DatosGato) -> void:
	if not nuevos:
		return
	if datos != nuevos:
		datos = nuevos
	imagen_normal = nuevos.imagen_normal
	imagen_bolita = nuevos.imagen_bolita
	imagen_orgulloso = nuevos.imagen_orgulloso
	escala_normal = nuevos.escala_normal
	escala_bolita = nuevos.escala_bolita
	fuerza_disparo = nuevos.fuerza_disparo
	impactos_maximos = nuevos.impactos_maximos
	if sprite:
		sprite.self_modulate = nuevos.tinte
	if animation_player and nuevos.animaciones and animation_player.get_animation_library(&"") != nuevos.animaciones:
		animation_player.stop()
		if animation_player.has_animation_library(&""):
			animation_player.remove_animation_library(&"")
		animation_player.add_animation_library(&"", nuevos.animaciones)
	aplicar_orgulloso()


func aplicar_orgulloso() -> void:
	if sprite:
		sprite.texture = imagen_orgulloso if orgulloso else imagen_normal
		sprite.scale = Vector2.ONE * escala_normal
	emitir_particulas(orgulloso)
