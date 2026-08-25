class_name NivelData
extends Resource

@export var nombre : String = "nivel"
@export var formas : Array[FormaData] = []
@export var posicion_divisiones : Vector2 = Vector2(0, 720)
@export var ancho_divisiones : float = 1280.0
@export_range(0.1, 1.0, 0.05) var porcentaje_ovillos_requerido : float = 0.20
