class_name TextoViewer
extends Control

@export var label_viewer : Label
var tween : Tween = null
var posicion_inicial : Vector2 = position

func _ready() -> void:
	animar_texto()

func set_texto(texto : String):
	label_viewer.text = texto
	#var color_real = Color.from_string(color, Color.WHITE) #si no pudiera transformarlo a color real lo pone en negro
	#label_viewer.label_settings.font_color = color_real


func animar_texto():
	efecto_animar_texto2()


func efecto_animar_texto2():
	scale = Vector2.ONE
	modulate.a = 1.0
	position = posicion_inicial
	var distancia_x := randf_range(-80.0, 80.0)
	var distancia_y := randf_range(-11.0, -50.0)
	var posicion_final := posicion_inicial + Vector2(distancia_x,distancia_y)
	tween = create_tween()

	#mover y desvanecer al mismo tiempo
	tween.set_parallel(true)
	tween.tween_property(self,"position",posicion_final,2.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self,"modulate:a",0.0, 2.8).set_trans(Tween.TRANS_LINEAR)
	tween.set_parallel(false)
	#tween.tween_callback(queue_free)
	await tween.finished
	queue_free()
