@icon("res://assets/sprite_ovillos/Ovillo verde.png")
class_name Ovillo
extends StaticBody2D

@export var tipo_ovillo : OvilloBase

@export_group("NODOS")
@export var audio : AudioStreamPlayer
@export var forma_colision : CollisionShape2D
@export var sprite_normal : Sprite2D
@export var sprite_desactivado : Sprite2D
@export var pergamino_info : PergaminoInfo
@export var numero_impacto : NumeroImpacto
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
	#numero_impacto.iniciar_numero_impacto(tipo_ovillo.cant_monedas)
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

func explotar():
	pass

func congelar():
	pass
