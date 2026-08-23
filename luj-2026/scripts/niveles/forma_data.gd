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
