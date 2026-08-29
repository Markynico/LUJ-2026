class_name PergaminoInfo
extends PanelContainer

var tween : Tween = null
@onready var nombre_text: RichTextLabel = %NombreText
@onready var info_text: RichTextLabel = %InfoText


func _ready() -> void:
	hide()

func _on_mouse_entered() -> void:
	print("mostrar")
	set_activo(true)

func _on_mouse_exited() -> void:
	print("esconder")
	set_activo(false)

func set_activo(activar : bool):
	if activar:
		show()
		modulate.a = 0.0
		tween_opacidad(1.0)
	else:
		modulate.a = 1.0
		tween_opacidad(0.0)
		hide()

func set_texto_ovillo(tipo_ovillo : OvilloBase): #probandooooo, ya chusmeo si hago una funcion para ovillo y otra para bolita o todo en una
	nombre_text.text = tipo_ovillo.nombre
	#descr = tipo_ovillo.descripcion
	info_text.text = "al golpear suma " + str(tipo_ovillo.cant_monedas) + " monedas"


func tween_opacidad(valor_final : float):
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "modulate:a", valor_final, 0.3)
