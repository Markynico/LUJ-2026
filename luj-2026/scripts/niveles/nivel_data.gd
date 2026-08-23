class_name NivelData
extends Resource

@export var nombre : String = "nivel"
@export var formas : Array[FormaData] = []
##cantidad de divisores entre los dos de los costados en la parte de abajo
@export_range(0, 20, 1) var divisiones_intermedias : int = 2
@export var posicion_divisiones : Vector2 = Vector2(0, 720)
@export var ancho_divisiones : float = 1280.0
