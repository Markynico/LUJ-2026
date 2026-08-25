@tool
class_name SalidaDeNivel
extends Area2D

signal elegida(salida : SalidaDeNivel)

##tipo de sala a la que lleva esta salida
@export var tipo : TipoDeSala.Tipo = TipoDeSala.Tipo.NORMAL:
	set(valor):
		tipo = valor
		queue_redraw()
##ancho y alto del area
@export var tamaño : Vector2 = Vector2(100.0, 200.0):
	set(valor):
		tamaño = valor.max(Vector2.ONE)
		actualizar_forma()
@export var colision : CollisionShape2D


func _ready() -> void:
	actualizar_forma()
	body_entered.connect(al_entrar_cuerpo)


func actualizar_forma() -> void:
	if not colision:
		return
	if not colision.shape:
		colision.shape = RectangleShape2D.new()
	colision.shape.size = tamaño
	colision.position = Vector2(0, -tamaño.y * 0.5)
	queue_redraw()


func _on_body_entered(body : Node2D) -> void:
	elegida.emit(self)


func _draw() -> void:
	draw_rect(Rect2(-tamaño.x * 0.5, -tamaño.y, tamaño.x, tamaño.y), TipoDeSala.COLORES[tipo])
