@tool
class_name Obstaculo
extends StaticBody2D

##forma que define el contorno solido, por defecto el padre
@export var forma : Node2D
@export var color : Color = Color(0.85, 0.85, 0.85)

var colision : CollisionPolygon2D


func _ready() -> void:
	if not forma:
		forma = get_parent()
	if forma.has_signal("forma_cambiada"):
		forma.forma_cambiada.connect(actualizar)
	actualizar()


func actualizar() -> void:
	if not forma or not forma.has_method("obtener_contorno"):
		return
	if not colision:
		colision = CollisionPolygon2D.new()
		add_child(colision)
	colision.polygon = forma.obtener_contorno()
	queue_redraw()


func _draw() -> void:
	if colision and colision.polygon.size() >= 3:
		draw_colored_polygon(colision.polygon, color)
