class_name NivelData
extends Resource

@export_range(1, 5, 1) var dificultad : int = 1
@export var nombre : String = "nivel"
@export var formas : Array[FormaData] = []
@export var posicion_divisiones : Vector2 = Vector2(0, 720)
@export var ancho_divisiones : float = 1280.0
