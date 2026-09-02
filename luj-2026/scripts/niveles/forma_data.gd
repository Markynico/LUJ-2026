@tool
class_name FormaData
extends Resource

##tipo de forma, se usa para saber que escena instanciar al cargar el nivel
@export var tipo : String = "rectangulo"
@export var posicion : Vector2
@export var rotacion : float = 0.0
@export var escala : Vector2 = Vector2.ONE
@export var separacion_ovillos : float = 50.0
@export var anillos_interiores : int = 0
@export var anillos_exteriores : int = 0
@export var separacion_anillos : int = 40
@export var repeticiones : int = 0
@export var separacion_repeticiones : int = 80
@export var eje_repeticiones : int = 0
@export var offset_repeticiones : Vector2 = Vector2.ZERO
@export var velocidad_desplazamiento : float = 0.0
@export var invertir_desplazamiento : bool = false
@export var alternar_direccion_anillos : bool = false
@export var alternar_direccion_repeticiones : bool = false
@export var efecto_ladrillo : bool = false
@export var recorrido_invertido : bool = false
@export var usar_simetria : bool = false
@export var arranque_invertido : bool = false
@export var copias_recorrido : int = 0
@export var grupo_simetria : int = 0
@export var rol_simetria : Vector2i = Vector2i.ZERO
@export var huecos : PackedInt32Array = PackedInt32Array()
@export var tamaño : Vector2 = Vector2(200, 100)
@export var radio : float = 100.0
@export var largo : float = 200.0
@export var poligono : PackedVector2Array = PackedVector2Array()
@export var angulo_grilla : float = 0.0
@export var separacion_filas : int = 50
@export var offset_grilla : Vector2 = Vector2.ZERO
@export var alternar_direccion_filas : bool = false
@export var curva : Curve2D
@export var recorrido : Curve2D
@export var posicion_recorrido : Vector2
@export var rotacion_recorrido : float = 0.0
@export var escala_recorrido : Vector2 = Vector2.ONE
@export var velocidad : float = 100.0
@export var bucle : bool = false
@export var ida_y_vuelta : bool = true
@export var rotar_con_el_path : bool = false
@export_range(0.0, 100.0, 1.0) var progreso_inicial : float = 0.0
