@tool
class_name GatoStats
extends Node2D

##escala del gato entero, particulas incluidas
@export var escala : float = 1.0:
	set(valor):
		escala = valor
		scale = Vector2.ONE * valor
##sprite que se muestra cuando se gana la run
@export var sprite_victoria : Texture2D
##sprite que se muestra cuando se pierde la run
@export var sprite_derrota : Texture2D
##alterna entre el sprite de victoria y el de derrota
@export var mostrar_victoria : bool = true:
	set(valor):
		mostrar_victoria = valor
		aplicar()
##corrimiento de posicion del sprite de derrota respecto al de victoria
@export var offset_posicion_derrota : Vector2 = Vector2.ZERO:
	set(valor):
		offset_posicion_derrota = valor
		aplicar()
##multiplicador de escala del sprite de derrota respecto al de victoria
@export var escala_derrota : float = 1.0:
	set(valor):
		escala_derrota = valor
		aplicar()

@export_group("Nodos")
@export var sprite : Sprite2D
@export var particulas : CPUParticles2D

var posicion_base_sprite : Vector2 = Vector2.ZERO
var escala_base_sprite : Vector2 = Vector2.ONE
var base_capturada : bool = false


func _ready() -> void:
	if not Engine.is_editor_hint() and Global.gato_elegido:
		if Global.gato_elegido.sprite_victoria:
			sprite_victoria = Global.gato_elegido.sprite_victoria
		if Global.gato_elegido.sprite_derrota:
			sprite_derrota = Global.gato_elegido.sprite_derrota
		if sprite:
			sprite.self_modulate = Global.gato_elegido.tinte
	aplicar()


func mostrar(gano : bool) -> void:
	mostrar_victoria = gano
	if particulas:
		particulas.emitting = gano


func aplicar() -> void:
	if not sprite or not is_inside_tree():
		return
	if not base_capturada:
		base_capturada = true
		posicion_base_sprite = sprite.position
		escala_base_sprite = sprite.scale
	if mostrar_victoria:
		sprite.texture = sprite_victoria
		sprite.position = posicion_base_sprite
		sprite.scale = escala_base_sprite
	else:
		sprite.texture = sprite_derrota
		sprite.position = posicion_base_sprite + offset_posicion_derrota
		sprite.scale = escala_base_sprite * escala_derrota
