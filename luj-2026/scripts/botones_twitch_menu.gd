extends Control

@export var texto_sin_conectar : Control
@export var texto_conectado : Control
@export var label_contador : Label
@export var audio_conectado : AudioStreamPlayer

@export var reliquia_regalo : Reliquia #le regalamos el almohadon pa q tengan una vida mas :D
@export var maximo_caricias : int = 20

func _ready() -> void:
	Global.twitch_conectado.connect(_on_twitch_conectado)
	Global.caricia_realizada.connect(aumentar_contador_caricias)
	Global.reliquia_a_regalar = reliquia_regalo
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
	if contador>= maximo_caricias and Global.regalar_reliquia == false: #false para saber q no regale  reliquia antes
		print("dar una reliquiaaaaaaaaaaaaaaaa")
		Global.regalar_reliquia = true
		Notificaciones.mostrar_desbloqueo(reliquia_regalo)
	if Global.regalar_reliquia == true:
		label_contador.text = str(contador) + " / 20 ¡reliquia obtenida!"
	else:
		label_contador.text = str(contador) + " / 20 para obtener una reliquia"
