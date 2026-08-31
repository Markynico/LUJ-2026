class_name PergaminoInfo
extends PanelContainer

var tween : Tween = null
var tipo_ovillo_mostrado : OvilloBase
@onready var nombre_text: RichTextLabel = %NombreText
@onready var info_text: RichTextLabel = %InfoText

#TODO consulta, sacamo el pergamino de la bola de pelos????? 

func _ready() -> void:
	hide()

func _on_mouse_entered() -> void:
	print("mostrar (en pergamino)")
	set_activo(true)

func _on_mouse_exited() -> void:
	print("esconder (en pergamino)")
	set_activo(false)

func set_activo(activar : bool):
	if activar:
		actualizar_texto()
		show()
		modulate.a = 0.0
		tween_opacidad(1.0)
	else:
		modulate.a = 1.0
		tween_opacidad(0.0)
		hide()

func set_texto_ovillo(tipo_ovillo : OvilloBase): #probandooooo, ya chusmeo si hago una funcion para ovillo y otra para bolita o todo en una
	tipo_ovillo_mostrado = tipo_ovillo
	actualizar_texto()

func set_texto_bolapelos(tipo_pelotita : PelotitaBase): #parece q no funca
	if tipo_ovillo_mostrado == null:
		return
	print("tipo pelotita anda? ", tipo_pelotita)
	nombre_text.text = tipo_pelotita.efectos[0].nombre_comida #siempre debe tener al menos un efecto, sino revisar q puede dar algun bug
	info_text.text = tipo_ovillo_mostrado.descripcion


func actualizar_texto():
	var puntos : int
	if not tipo_ovillo_mostrado:
		return
	puntos = roundi(tipo_ovillo_mostrado.puntaje * ReliquiasManager.multiplicador_puntos_para(tipo_ovillo_mostrado))
	nombre_text.text = tipo_ovillo_mostrado.nombre
	info_text.text = tipo_ovillo_mostrado.descripcion.format({"puntos": puntos, "monedas": tipo_ovillo_mostrado.cant_monedas})


func tween_opacidad(valor_final : float):
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "modulate:a", valor_final, 0.3)
