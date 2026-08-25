class_name NumeroImpacto
extends Label

var tween : Tween = null
var posicion_inicial : Vector2 = position

func _ready() -> void:
	hide()
	reiniciar_valores()

func iniciar_numero_impacto(numero : int):
	text = str(numero)
	show()
	todo_junto(1.0)
	#tween_opacidad(1.0)
	#tween_escala(Vector2(0.9, 0.9), 0.1)
	#tween_escala(Vector2(1.3, 1.3), 5)
	#tween_opacidad(0.0)
	
	#tween_escala(Vector2(0.1, 0.1), 1)
	

func reiniciar_valores(): #por si el ovillo se puede volver a activar el numerito deberia volver a funcionar (?
	modulate.a = 0
	#position = posicion_inicial


func animacion_numerito():
	pass


func todo_junto(valor_final : float, tiempo : float = 0.3):
	tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "modulate:a", valor_final, tiempo)
	
	#tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "scale", Vector2(0.9, 0.9) , 0.3)
	
	#tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "scale", Vector2(1.2, 1.2) , 0.8)
	
	#tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)

func tween_opacidad(valor_final : float, tiempo : float = 0.3):
	#if tween:
		#tween.kill()
	tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "modulate:a", valor_final, tiempo)


func tween_escala(valor_final : Vector2, tiempo : float = 0.3):
	#if tween:
		#tween.kill()
	tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "scale", valor_final , 0.3)
