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
@export var shader_titilar : ShaderMaterial
var tween : Tween
var activado : bool = true

func _ready() -> void:
	sprite_desactivado.hide()
	audio.stream = tipo_ovillo.audio
	sprite_normal.texture = tipo_ovillo.sprite
	pergamino_info.set_texto_ovillo(tipo_ovillo)

func recibir_impacto() -> void: #se llama desde la bola de pelos al impactar con esto
	if not activado:
		return
	desactivar_ovillo()
	numero_impacto.iniciar_numero_impacto(tipo_ovillo.cant_monedas) #holi aca poner puntaje en vez de monedas
	for efecto in tipo_ovillo.efectos_al_recibir_impacto:
		efecto.al_recibir_impacto(self)
		#emitir dar monedas tipo_ovillo.cantidadmondedas
		pass

func desactivar_ovillo():
	forma_colision.set_deferred("disabled", true)
	sprite_normal.hide()
	sprite_desactivado.show()
	audio.play()
	activado = false

func reactivar_ovillo(): #por si hay bolas de pelo q puedan reactivar los ovillos como en el peglin
	if not activado:
		#aca le meto el codigo dsp
		pass

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

func congelar():
	pass


func animacion_titilar(shader_real : ShaderMaterial):
	shader_real.set_shader_parameter("time", 0.0) #inicializo en 0.0
	tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(shader_real,"shader_parameter/time",1.0,1)
