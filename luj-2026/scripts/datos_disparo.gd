class_name DatosDisparo
extends RefCounted

var velocidad_inicial : Vector2 = Vector2.ZERO
var gravedad : Vector2 = Vector2(0, ProjectSettings.get_setting("physics/2d/default_gravity"))
var fuerza_rebote : float = 200.0
var restitucion : float = 0.85
var friccion : float = 0.6
var radio : float = 11.0
var amortiguacion_angular : float = 1.0
var rebotes : int = 0
var pasos : int = 120
var intervalo : float = 1.0 / 60.0
