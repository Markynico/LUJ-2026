class_name TrayectoriaDisparo
extends Line2D

@export var disparador : DisparadorPelotita
@export var distancia_maxima: float = 6.0
@export var intervalo: float = 0.05
@export var detector_colisiones : CharacterBody2D
var gravedad = ProjectSettings.get_setting("physics/2d/default_gravity")

func _process(delta: float):
	dibujar_trayectoria()
	#actualizar_trayectoria()

#probar con raycast en vez de characterbody
func actualizar_trayectoria():
	clear_points()
	var posicion_inicial := disparador.global_position
	var velocidad_inicial := -disparador.velocidad_inicial #se calcula segun la posicion del mouse, mientras mas lejos mas fuerte disparo
	var gravedad_real : Vector2 = Vector2(0, 980)
	for i in 12:
		var delta_simulacion := intervalo
		velocidad_inicial.y += gravedad * delta_simulacion
		var movimiento := velocidad_inicial * delta_simulacion
		var colision := detector_colisiones.move_and_collide(movimiento)
		if colision:
			velocidad_inicial = velocidad_inicial.bounce(colision.get_normal())
		posicion_inicial += movimiento
		add_point(to_local(posicion_inicial))
		detector_colisiones.global_position = posicion_inicial

func dibujar_trayectoria(): #este metodo anda
	clear_points()
	var posicion_inicial := disparador.global_position
	var velocidad_inicial := -disparador.velocidad_inicial #se calcula segun la posicion del mouse, mientras mas lejos mas fuerte disparo
	for i in distancia_maxima: #probando
		var tiempo := i * intervalo
		#uso la formula esta de fisica q dice ( x= x0 + vi * t + 1/2 * aceleracion * t al cuadrado ) si, como te diste cuenta q no me gustaba fisica en la escuela
		var posicion = (posicion_inicial+ velocidad_inicial * tiempo+ 0.5 * Vector2(0,980) * tiempo * tiempo)
		var posicion_local = to_local(posicion)
		add_point(posicion_local)
