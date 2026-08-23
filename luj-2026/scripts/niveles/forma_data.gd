class_name FormaData
extends Resource

##tipo de forma, se usa para saber que escena instanciar al cargar el nivel
@export var tipo : String = "rectangulo"
@export var posicion : Vector2
@export var rotacion : float = 0.0
@export var escala : Vector2 = Vector2.ONE
@export var separacion_ovillos : float = 50.0
@export var tamaño : Vector2 = Vector2(200, 100)
@export var radio : float = 100.0
@export var curva : Curve2D
@export var recorrido : Curve2D
@export var posicion_recorrido : Vector2
@export var velocidad : float = 100.0
@export var bucle : bool = false
@export var ida_y_vuelta : bool = true
@export var rotar_con_el_path : bool = false
@export_range(0.0, 100.0, 1.0) var progreso_inicial : float = 0.0
