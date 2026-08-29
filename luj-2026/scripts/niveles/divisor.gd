@tool
class_name Divisor
extends StaticBody2D

##alto de la pared en pixeles
@export var alto : float = 150.0:
	set(valor):
		alto = max(valor, 1.0)
		actualizar_formas()
##ancho de la pared en pixeles
@export var ancho : float = 20.0:
	set(valor):
		ancho = max(valor, 1.0)
		actualizar_formas()
##radio del circulo de la punta, por defecto acompaña al ancho
@export var radio_punta : float = 10.0:
	set(valor):
		radio_punta = max(valor, 1.0)
		actualizar_formas()
@export var color : Color = Color(0.85, 0.85, 0.85):
	set(valor):
		color = valor
		queue_redraw()
@export var colision_pared : CollisionShape2D
@export var colision_punta : CollisionShape2D
##corrimiento vertical del sprite del soporte en pixeles
@export var offset_soporte : float = 0.0:
	set(valor):
		offset_soporte = valor
		actualizar_formas()
@export var sprite_soporte : Sprite2D
@export var sprite_bola : Sprite2D


func _ready() -> void:
	actualizar_formas()


func actualizar_formas() -> void:
	if not colision_pared or not colision_punta:
		return
	var forma_pared : RectangleShape2D = colision_pared.shape
	forma_pared.size = Vector2(ancho, alto)
	colision_pared.position = Vector2(0, -alto * 0.5)
	var forma_punta : CircleShape2D = colision_punta.shape
	forma_punta.radius = radio_punta
	colision_punta.position = Vector2(0, -alto)
	actualizar_sprites()
	queue_redraw()


func actualizar_sprites() -> void:
	if sprite_soporte:
		var tamaño_soporte : Vector2 = sprite_soporte.region_rect.size
		var escala_soporte : float = ancho / tamaño_soporte.x
		sprite_soporte.scale = Vector2.ONE * escala_soporte
		sprite_soporte.position = Vector2(0, -alto + tamaño_soporte.y * escala_soporte * 0.5 + offset_soporte)
	if sprite_bola:
		var tamaño_bola : Vector2 = sprite_bola.region_rect.size
		sprite_bola.scale = Vector2(radio_punta * 2.0 / tamaño_bola.x, radio_punta * 2.0 / tamaño_bola.y)
		sprite_bola.position = Vector2(0, -alto)


func _draw() -> void:
	if sprite_soporte and sprite_bola:
		return
	draw_rect(Rect2(-ancho * 0.5, -alto, ancho, alto), color)
	draw_circle(Vector2(0, -alto), radio_punta, color)
