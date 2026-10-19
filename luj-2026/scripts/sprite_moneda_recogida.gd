@icon("res://assets/moneda cara.png")
class_name SpriteMonedaRecogida
extends Sprite2D

var tween : Tween
@onready var posicion_inicial : Vector2 = position

func _ready() -> void:
	iniciar_tween()


func iniciar_tween():
	#print("INICIA EL TWEEN")
	tween = create_tween()
	tween.set_trans(Tween.TRANS_EXPO) #con elastic tambien esta bueno pero pega un saltito al final medio raro
	tween.set_ease(Tween.EASE_OUT)
	tween.chain().set_parallel(true)
	
	var direccion = [-1,1].pick_random() #izq o derecha
	var distancia_x = randf_range(1.5, 4.0) * direccion
	var altura_y = randf_range(25.0, 35.0)
	
	tween.tween_property(self, "position:x", position.x + distancia_x , 0.7)
	tween.tween_property(self, "position:y", position.y - altura_y , 0.7)
	tween.tween_property(self, "modulate:a", 0.0, 0.6).set_trans(Tween.TRANS_CUBIC).set_delay(0.2)
	await tween.finished
	queue_free()
