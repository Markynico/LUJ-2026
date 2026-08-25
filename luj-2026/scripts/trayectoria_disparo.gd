class_name TrayectoriaDisparo
extends Line2D

@export var disparador : DisparadorPelotita
@export var distancia_maxima: float = 25.0
@export var intervalo: float = 0.05

func _physics_process(delta: float) -> void:
	dibujar_trayectoria()


func dibujar_trayectoria():
	clear_points()
	var posicion_inicial := disparador.global_position
	var velocidad_inicial := -disparador.velocidad_inicial
	for i in 10: #probando
		var tiempo := i * intervalo
		var posicion = (posicion_inicial+ velocidad_inicial * tiempo+ 0.5 * Vector2(0,980) * tiempo * tiempo)
		var posicion_local = to_local(posicion)
		add_point(posicion_local)
