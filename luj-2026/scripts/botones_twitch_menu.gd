extends Control

@export var texto_sin_conectar : Control
@export var texto_conectado : Control
@export var label_contador : Label
@export var audio_conectado : AudioStreamPlayer

@export var reliquia_a_regalar : Reliquia #le regalamos el almohadon pa q tengan una vida mas :D

func _ready() -> void:
	Global.twitch_conectado.connect(_on_twitch_conectado)
	Global.caricia_realizada.connect(aumentar_contador_caricias)
	texto_conectado.hide()


func _on_twitch_conectado(estado : bool):
	if estado == true:
		print("conectado correctamente, esconder texto y boton")
		audio_conectado.play()
		texto_sin_conectar.hide()
		texto_conectado.show()
	else:
		print("no se pudo conectar")


func aumentar_contador_caricias(contador : int):
	if contador>=20:
		print("dar una reliquiaaaaaaaaaaaaaaaa")
	label_contador.text = str(contador) + " / 20 para desbloquear una reliquia"
