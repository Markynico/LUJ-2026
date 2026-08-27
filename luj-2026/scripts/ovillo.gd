@icon("res://assets/sprite_ovillos/Ovillo verde.png")
class_name Ovillo
extends StaticBody2D

@export var tipo_ovillo : OvilloBase

@export_group("NODOS")
@export var audio : AudioStreamPlayer
@export var forma_colision : CollisionShape2D
@export var sprite_normal : Sprite2D #el sprite normal es el q va a contener el shader de titilar antes de explotar
@export var sprite_desactivado : Sprite2D
@export var pergamino_info : PergaminoInfo
@export var numero_impacto : NumeroImpacto

signal ovillo_desactivado(ovillo: Ovillo)

@export var shader_titilar : ShaderMaterial
var tween : Tween
var activado : bool = true

var multiplicador : int = 1 #para ovillo_catnip

func _ready() -> void:
	add_to_group("ovillos")
	if sprite_desactivado:
		sprite_desactivado.hide()
	if tipo_ovillo:
		if audio and tipo_ovillo.audio:
			audio.stream = tipo_ovillo.audio
		if sprite_normal and tipo_ovillo.sprite:
			sprite_normal.texture = tipo_ovillo.sprite
		if pergamino_info:
			pergamino_info.set_texto_ovillo(tipo_ovillo)
	
	# Auto-registrarse en GameManager
	if GameManager.instancia_actual:
		GameManager.instancia_actual.registrar_ovillo(self)

func recibir_impacto() -> void: # Se llama desde la bola de pelos al impactar
	if not activado:
		return
	desactivar_ovillo()
	numero_impacto.iniciar_numero_impacto(obtener_puntaje()) #le cambie monedas x puntaje
	for efecto in tipo_ovillo.efectos_al_recibir_impacto:
		efecto.al_recibir_impacto(self)
	
	
#forzar github
	#numero_impacto.iniciar_numero_impacto(tipo_ovillo.cant_monedas) #holi aca poner puntaje en vez de monedas
	#for efecto in tipo_ovillo.efectos_al_recibir_impacto:
	#	efecto.al_recibir_impacto(self)
		#emitir dar monedas tipo_ovillo.cantidadmondedas
	#	pass

#
func desactivar_ovillo() -> void:
	if not activado:
		return
	activado = false
	if forma_colision:
		forma_colision.set_deferred("disabled", true)
	if sprite_normal:
		sprite_normal.hide()
	if sprite_desactivado:
		sprite_desactivado.show()
	if audio and audio.stream:
		audio.play()
	
	ovillo_desactivado.emit(self)
	
	# Notificar a GameManager
	if GameManager.instancia_actual:
		GameManager.instancia_actual.registrar_ovillo_destruido(self)

func reactivar_ovillo() -> void:
	if activado:
		return
	activado = true
	if forma_colision:
		forma_colision.set_deferred("disabled", false)
	if sprite_normal:
		sprite_normal.show()
	if sprite_desactivado:
		sprite_desactivado.hide()


func explotar(nodo_explosion : Explosion): #lo llamo en el EfectoExplosion
	sprite_normal.show() #lo muestro a proposito pq cuando lo desactivo se esconde, es solo visual
	sprite_desactivado.hide()
	sprite_normal.material = shader_titilar.duplicate() #ahora sprite tiene el shader, onda adentro del material esta el shader
	var shader_real : ShaderMaterial = sprite_normal.material
	animacion_titilar(shader_real)
	await tween.finished
	sprite_normal.hide() #los vuelvo a esconder como si se hubiera desactivado recien ahora
	sprite_desactivado.show()
	nodo_explosion.activar_explosion()
	tween.kill()

func duplicar_recompensas() -> void: #la llama efecto_ovillo_catnip
	if !activado:
		return
	print("MULTIPLICÓ")
	multiplicador = 2
	

func fin_duplicar() -> void:
	if !activado:
		return
	multiplicador = 1

func obtener_puntaje () -> int:
	if not tipo_ovillo:
		return 0
	#print(name, " puntaje: ", tipo_ovillo.puntaje, " x ", multiplicador)
	return tipo_ovillo.puntaje * multiplicador

func obtener_monedas () -> int:
	if not tipo_ovillo:
		return 0
	return tipo_ovillo.cant_monedas * multiplicador

func congelar() -> void:
	pass


func animacion_titilar(shader_real : ShaderMaterial):
	shader_real.set_shader_parameter("time", 0.0) #inicializo en 0.0
	tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(shader_real,"shader_parameter/time",1.0,1)
