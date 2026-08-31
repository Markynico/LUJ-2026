@tool
class_name Obstaculo
extends StaticBody2D

##forma que define el contorno solido, por defecto el padre
@export var forma : Node2D
@export var color : Color = Color(0.85, 0.85, 0.85):
	set(valor):
		color = valor
		queue_redraw()
##color del borde interior
@export var color_borde : Color = Color(0.55, 0.55, 0.55):
	set(valor):
		color_borde = valor
		queue_redraw()
##grosor del borde interior en pixeles, 0 = sin borde
@export var grosor_borde : float = 0.0:
	set(valor):
		grosor_borde = maxf(valor, 0.0)
		queue_redraw()

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
		colision.visible = false
		add_child(colision)
	colision.polygon = forma.obtener_contorno()
	queue_redraw()


func _draw() -> void:
	var interiores : Array[PackedVector2Array]
	if not colision or colision.polygon.size() < 3:
		return
	if grosor_borde <= 0.0:
		draw_colored_polygon(colision.polygon, color)
		return
	draw_colored_polygon(colision.polygon, color_borde)
	interiores = Geometry2D.offset_polygon(colision.polygon, -grosor_borde)
	for interior in interiores:
		if interior.size() >= 3:
			draw_colored_polygon(interior, color)
