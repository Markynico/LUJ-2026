class_name NumeroImpacto
extends Label

##cuando aparezca un numerito, va a aumentar su tamaño segun el valor del numero y este factor de aumento. es decir, si sale el numero 1, sera de tamaño normal, pero si sale el numero 5 saldra (escala + 5 * factor de aumento) veces mas grande- En resumen, mientra mas grande el valor del factor de aumento mas grande sera el numero 
@export var factor_aumento : float = 0.04
@export var maximo_aumento_escala : float = 0.9
var tween : Tween = null
var posicion_inicial : Vector2 = position
var escala_inicial : Vector2

func _ready() -> void:
	escala_inicial = scale
	pivot_offset = size / 2.0
	hide()
	#reiniciar_valores()

func iniciar_numero_impacto(numero : int, color_numero : Color = Color.WHITE):
	scale = escala_inicial #reinicio
	var aumento : float = calcular_aumento_escala(numero)
	text = str(numero)
	set("theme_override_colors/font_color",color_numero)
	show()
	efecto_punch_parabolico(aumento)

func mostrar_texto_impacto(texto : String):
	text = texto
	show()
	efecto_punch_parabolico()

#TODO esta funcion no se usa, perooo si metemos que algun ovillo pueda volver a activarse vamos a necesitar reiniciar
func reiniciar_valores():
	scale = Vector2.ONE #reinicio valores
	modulate.a = 1.0
	position = posicion_inicial 
	pass


func efecto_punch_parabolico(aumento_escala : float = 0.0):
	#scale = Vector2.ONE #reinicio valores
	modulate.a = 1.0
	position = posicion_inicial 
	#aca randomizo q a veces salte para la izquierda y a veces para la derecha y tambien varia el movimmiento
	var direccion = [-1,1].pick_random() #izq o derecha
	var distancia_x = randf_range(20.0, 80.0) * direccion
	var altura_y = randf_range(30.0, 60.0)
	tween = create_tween()
	#efecto punch
	tween.tween_property(self, "scale", Vector2(2.0 + aumento_escala, 2.0 + aumento_escala), 0.15).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_interval(0.1) #aca pega una pausa
	#saltito parabolico
	tween.chain().set_parallel(true)#resulta q con chain todo lo q sigue se ejecuta al mismo tiempo
	tween.tween_property(self, "scale", Vector2(0.8, 0.8), 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position:x", posicion_inicial.x + distancia_x, 0.9).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "position:y", posicion_inicial.y - altura_y, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:y", posicion_inicial.y + (altura_y * 0.5), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN).set_delay(0.2)
	tween.tween_property(self, "modulate:a", 0.0, 0.2).set_delay(0.15)
	#marge no voy a mentirte
	#la referencia viene de aca https://forum.godotengine.org/t/hit-style-tweens/92906/5 pero use ia pq sino no terminaba ma


func calcular_aumento_escala(numero_puntaje : int):
	var aumento_escala : float = 0.0
	if numero_puntaje != 1:
		aumento_escala = numero_puntaje * factor_aumento
	return clampf(aumento_escala, 0.0, maximo_aumento_escala)
