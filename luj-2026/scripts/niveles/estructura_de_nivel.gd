@tool
class_name EstructuraDeNivel
extends Node2D

##pared que define el borde izquierdo de la zona jugable
@export var pared_izquierda : StaticBody2D
##pared que define el borde derecho de la zona jugable
@export var pared_derecha : StaticBody2D
##piso del gato, define el borde superior de la zona jugable
@export var piso_gato : StaticBody2D


func zona_jugable() -> Rect2:
	var izquierda : float = rect_global_de(pared_izquierda).end.x
	var derecha : float = rect_global_de(pared_derecha).position.x
	var arriba : float = rect_global_de(piso_gato).end.y
	var abajo : float = to_global(Vector2(0, ProjectSettings.get_setting("display/window/size/viewport_height"))).y
	return Rect2(izquierda, arriba, derecha - izquierda, abajo - arriba)


func rect_global_de(cuerpo : StaticBody2D) -> Rect2:
	var colision : CollisionShape2D = null
	for hijo in cuerpo.get_children():
		if hijo is CollisionShape2D:
			colision = hijo
			break
	return colision.get_global_transform() * colision.shape.get_rect()
