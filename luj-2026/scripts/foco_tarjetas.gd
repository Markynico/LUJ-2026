class_name FocoTarjetas
extends Control

signal accion_pedida(tarjeta : Tarjeta)
signal cerrado(tarjeta : Tarjeta)

##segundos de la animacion de foco
@export var duracion : float = 0.4
##escala de la tarjeta cuando esta en foco
@export var escala_foco : float = 1.5
##separacion fija de los botones con los bordes de la tarjeta
@export var separacion_botones : float = 40.0
##escala del boton de accion cuando esta en foco
@export var escala_boton_accion : float = 1.6
##si se muestra el boton de accion a la derecha de la tarjeta
@export var con_accion : bool = true

@export_group("Nodos")
@export var capa : Control
@export var oscurecedor : ColorRect
@export var boton_volver : Button
@export var boton_accion : Button

var tarjeta_actual : Tarjeta
var padre_original : Node
var indice_original : int = 0
var nodo_retorno : Control
var posicion_original : Vector2
var posicion_local_original : Vector2
var escala_original : Vector2
var posicion_retorno : Vector2
var tween : Tween


func _ready() -> void:
	hide()
	boton_volver.pressed.connect(cerrar)
	boton_accion.pressed.connect(al_accion)
	oscurecedor.gui_input.connect(al_click_oscurecedor)


func esta_abierto() -> bool:
	return tarjeta_actual != null


func abrir(tarjeta : Tarjeta, retorno : Control = null) -> void:
	var centro : Vector2 = get_viewport_rect().size * 0.5
	var destino : Vector2 = centro - tarjeta.size * escala_foco * 0.5
	if tarjeta_actual:
		return
	tarjeta_actual = tarjeta
	nodo_retorno = retorno
	posicion_original = tarjeta.global_position
	posicion_local_original = tarjeta.position
	escala_original = tarjeta.scale
	tarjeta.hover_activado = false
	tarjeta.mostrar_borde(false)
	padre_original = tarjeta.get_parent()
	indice_original = tarjeta.get_index()
	padre_original.remove_child(tarjeta)
	add_child(tarjeta)
	tarjeta.global_position = posicion_original
	capa.modulate.a = 0.0
	show()
	boton_volver.reset_size()
	boton_accion.reset_size()
	boton_accion.visible = con_accion
	boton_volver.global_position = Vector2(destino.x - separacion_botones - boton_volver.size.x, centro.y - boton_volver.size.y * 0.5)
	if nodo_retorno and con_accion:
		posicion_retorno = nodo_retorno.global_position
		boton_accion.global_position = posicion_retorno
		boton_accion.scale = escala_original
		nodo_retorno.hide()
	else:
		boton_accion.scale = Vector2.ONE * escala_boton_accion
		boton_accion.global_position = Vector2(destino.x + tarjeta.size.x * escala_foco + separacion_botones, centro.y - boton_accion.size.y * escala_boton_accion * 0.5)
	animar(destino, Vector2.ONE * escala_foco, 1.0)
	if nodo_retorno and con_accion:
		tween.tween_property(boton_accion, "global_position", Vector2(destino.x + tarjeta.size.x * escala_foco + separacion_botones, centro.y - boton_accion.size.y * escala_boton_accion * 0.5), duracion)
		tween.tween_property(boton_accion, "scale", Vector2.ONE * escala_boton_accion, duracion)


func cerrar() -> void:
	if not tarjeta_actual:
		return
	animar(posicion_original, escala_original, 0.0)
	if nodo_retorno:
		tween.tween_callback(entrar_nodo_retorno).set_delay(duracion * 0.55)
	tween.chain().tween_callback(terminar_cierre)


func animar(destino : Vector2, escala : Vector2, alpha : float) -> void:
	if tween:
		tween.kill()
	tween = create_tween().set_parallel().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.tween_property(tarjeta_actual, "global_position", destino, duracion)
	tween.tween_property(tarjeta_actual, "scale", escala, duracion)
	tween.tween_property(capa, "modulate:a", alpha, duracion)


func entrar_nodo_retorno() -> void:
	var tween_retorno : Tween
	if not nodo_retorno or not con_accion:
		if nodo_retorno:
			nodo_retorno.show()
		return
	tween_retorno = nodo_retorno.create_tween().set_parallel().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	nodo_retorno.show()
	nodo_retorno.modulate.a = 0.0
	nodo_retorno.position += Vector2(40.0, 0.0)
	tween_retorno.tween_property(nodo_retorno, "modulate:a", 1.0, 0.25)
	tween_retorno.tween_property(nodo_retorno, "position", nodo_retorno.position - Vector2(40.0, 0.0), 0.25)


func terminar_cierre() -> void:
	var tarjeta : Tarjeta = tarjeta_actual
	if not tarjeta:
		return
	remove_child(tarjeta)
	padre_original.add_child(tarjeta)
	padre_original.move_child(tarjeta, indice_original)
	tarjeta.position = posicion_local_original
	tarjeta.hover_activado = true
	boton_accion.scale = Vector2.ONE
	hide()
	tarjeta_actual = null
	nodo_retorno = null
	cerrado.emit(tarjeta)


func al_accion() -> void:
	accion_pedida.emit(tarjeta_actual)


func al_click_oscurecedor(evento : InputEvent) -> void:
	if evento is InputEventMouseButton and evento.button_index == MOUSE_BUTTON_LEFT and evento.pressed:
		cerrar()
