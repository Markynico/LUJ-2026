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
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func actualizar_forma() -> void:
	if not colision:
		return
	if not colision.shape:
		colision.shape = RectangleShape2D.new()
	colision.shape.size = tamaño
	colision.position = Vector2(0, -tamaño.y * 0.5)
	queue_redraw()


func _draw() -> void:
	var nombre : String = TipoDeSala.NOMBRES.get(tipo, "?")
	draw_rect(Rect2(-tamaño.x * 0.5, -tamaño.y, tamaño.x, tamaño.y), TipoDeSala.COLORES[tipo])
	draw_string(ThemeDB.fallback_font, Vector2(-tamaño.x * 0.5, -tamaño.y * 0.5), nombre, HORIZONTAL_ALIGNMENT_CENTER, tamaño.x, 18, Color.WHITE)


func _on_body_entered(body : Node2D) -> void:
	elegida.emit(self)
