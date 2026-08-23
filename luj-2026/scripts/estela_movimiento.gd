class_name EstelaMovimiento
extends Line2D

##distancia maxima de la estela de movimiento, a mayor valor mas larga es la estela
@export var distancia_maxima: float = 25.0
@export var body: BolaDePelos
 
func _ready() -> void:
	set_as_top_level(true)
 
 
func _physics_process(_delta: float) -> void:
	if not body:
		return
 
	add_point(body.global_position)
 
	if points.size() > distancia_maxima:
		remove_point(0)
