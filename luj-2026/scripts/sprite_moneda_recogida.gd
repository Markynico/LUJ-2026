@icon("res://assets/moneda cara.png")
class_name SpriteMonedaRecogida
extends Sprite2D

var tween : Tween
@onready var posicion_inicial : Vector2 = position

func _ready() -> void:
	iniciar_tween()


func iniciar_tween():
	print("SE INICIA EL TWEEN")
	tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.chain().set_parallel(true)
	
	var direccion = [-1,1].pick_random() #izq o derecha
	var distancia_x = randf_range(2.0, 8.0) * direccion
	var altura_y = randf_range(25.0, 35.0)
	
	tween.tween_property(self, "position:x", position.x + distancia_x , 1.3)
	tween.tween_property(self, "position:y", position.y - altura_y , 1.3)
	tween.tween_property(self, "modulate:a", 0.0, 0.7).set_trans(Tween.TRANS_CUBIC).set_delay(0.3)
	await tween.finished
	queue_free()







func efecto_punch_parabolico():
	scale = Vector2.ONE #reinicio valores
	modulate.a = 1.0
	position = posicion_inicial 
	#aca randomizo q a veces salte para la izquierda y a veces para la derecha y tambien varia el movimmiento
	var direccion = [-1,1].pick_random() #izq o derecha
	var distancia_x = randf_range(20.0, 80.0) * direccion
	var altura_y = randf_range(30.0, 60.0)
	tween = create_tween()
	#efecto punch
	tween.tween_property(self, "scale", Vector2(2.0, 2.0), 0.15).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_interval(0.1) #aca pega una pausa
	#saltito parabolico
	tween.chain().set_parallel(true)#resulta q con chain todo lo q sigue se ejecuta al mismo tiempo
	tween.tween_property(self, "scale", Vector2(0.8, 0.8), 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position:x", posicion_inicial.x + distancia_x, 0.9).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "position:y", posicion_inicial.y - altura_y, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:y", posicion_inicial.y + (altura_y * 0.5), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN).set_delay(0.2)
	tween.tween_property(self, "modulate:a", 0.0, 0.2).set_delay(0.15)
