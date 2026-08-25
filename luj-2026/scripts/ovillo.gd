@icon("res://assets/sprite_ovillos/Ovillo verde.png")
class_name Ovillo
extends StaticBody2D

@export var tipo_ovillo : OvilloBase

@export_group("NODOS")
@export var audio : AudioStreamPlayer
@export var forma_colision : CollisionShape2D
@export var sprite_normal : Sprite2D
@export var sprite_desactivado : Sprite2D

signal ovillo_desactivado(ovillo: Ovillo)

var activado : bool = true

func _ready() -> void:
	add_to_group("ovillos")
	if sprite_desactivado:
		sprite_desactivado.hide()
	if tipo_ovillo:
		if audio and tipo_ovillo.audio:
			audio.stream = tipo_ovillo.audio
		if sprite_normal and tipo_ovillo.sprite:
			sprite_normal.texture = tipo_ovillo.sprite
	
	# Auto-registrarse en GameManager
	if GameManager.instancia_actual:
		GameManager.instancia_actual.registrar_ovillo(self)

func recibir_impacto() -> void: # Se llama desde la bola de pelos al impactar
	if not activado:
		return
	desactivar_ovillo()
	if tipo_ovillo and tipo_ovillo.efectos_al_recibir_impacto:
		for efecto in tipo_ovillo.efectos_al_recibir_impacto:
			if efecto:
				efecto.al_recibir_impacto(self)

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

func explotar() -> void:
	pass

func congelar() -> void:
	pass
