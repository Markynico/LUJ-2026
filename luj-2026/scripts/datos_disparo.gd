class_name DatosDisparo
extends RefCounted

var velocidad_inicial : Vector2 = Vector2.ZERO
var gravedad : Vector2 = Vector2(0, ProjectSettings.get_setting("physics/2d/default_gravity"))
var fuerza_rebote : float = 200.0
var rebotes : int = 1
var pasos : int = 40
var intervalo : float = 0.05
