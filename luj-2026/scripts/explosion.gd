@icon("res://iconos_custom/explosion.svg")
class_name Explosion
extends Node2D

@export var area_2d: Area2D
@export var animated_sprite_explosion : AnimatedSprite2D
##si esta activado, la explosion empuja a las bolas de pelos
@export var empuja_bolas : bool = true
##fuerza del impulso que reciben las bolas en el centro de la explosion
@export var fuerza_impulso : float = 1500.0
##sonido que reemplaza al del ovillo cuando una reliquia potencio la explosion
@export var efecto_potenciada : EfectoDeSonido.Tipo = EfectoDeSonido.Tipo.EXPLOSION_GRANDE

var estado_a_aplicar : EstadoOvillo
var rompe_ovillos : bool = true
var potenciada : bool = false


func efecto_sonido(efecto_base : EfectoDeSonido.Tipo) -> EfectoDeSonido.Tipo:
	return efecto_potenciada if potenciada else efecto_base

func _ready() -> void:
	animated_sprite_explosion.animation_finished.connect(queue_free)


func activar_explosion(): #se llama desde OVILLO
	#sprite_2d.show()
	#$AnimationPlayer.play("probando")
	animated_sprite_explosion.play()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Ovillo:
		if estado_a_aplicar:
			body.aplicar_estado(estado_a_aplicar)
		if rompe_ovillos:
			body.recibir_explosion()
	if body is BolaDePelos and empuja_bolas:
		empujar_bola(body)


func empujar_bola(bola : BolaDePelos) -> void:
	var direccion : Vector2 = bola.global_position - global_position
	if direccion.is_zero_approx():
		direccion = Vector2.UP
	bola.apply_central_impulse(direccion.normalized() * fuerza_impulso)


func _on_sprites_explosion_frame_changed() -> void:
	if animated_sprite_explosion.frame == 18: #pq justo en la 22 hace la explosion grande
		#dsp la volvemos a timear con la animacion de verdad
		#de attie: lo baje a 18 porque 22 quedaba como con delay. ahora coincide con la visual y sfx 
		#print("DEBERIA REACTIVARRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR")
		reactivar_colisiones()


func reactivar_colisiones(): #en realidad esta es la funcion q nos ayuda a q otros ovillos exploten
	area_2d.set_deferred("monitoring", true)
	apagar_colisiones()


func apagar_colisiones() -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame
	if is_instance_valid(area_2d):
		area_2d.set_deferred("monitoring", false)
