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
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(-ancho * 0.5, -alto, ancho, alto), color)
	draw_circle(Vector2(0, -alto), radio_punta, color)
