@tool
class_name GuanteCaricia
extends Node2D

signal caricia_iniciada
signal caricia_terminada

##segundos del fade in y out del guante
@export var duracion_fade : float = 0.2
##veces que se repite la animacion por caricia
@export var repeticiones : int = 2
##segundos que tarda el guante en moverse entre el hover y la caricia
@export var duracion_movimiento : float = 0.25
##escala del sprite del guante
@export var escala_guante : float = 0.2 :
	set(valor):
		escala_guante = valor
		if guante:
			guante.scale = Vector2.ONE * escala_guante

@export_group("NODOS")
@export var guante : AnimatedSprite2D
@export var area : Area2D
@export var posicion_hover : Marker2D
@export var posicion_caricia : Marker2D

var activo : bool = false :
	set(valor):
		activo = valor
		if not activo:
			desaparecer()
		elif mouse_encima:
			mostrar_hover()
var mouse_encima : bool = false
var reproducciones_restantes : int = 0
var caricia_en_curso : bool = false
var tween_fade : Tween
var tween_movimiento : Tween


func _ready() -> void:
	guante.scale = Vector2.ONE * escala_guante
	if Engine.is_editor_hint():
		guante.visible = true
		guante.modulate.a = 1.0
		return
	guante.visible = false
	guante.modulate.a = 0.0
	area.mouse_entered.connect(al_entrar_mouse)
	area.mouse_exited.connect(al_salir_mouse)
	area.input_event.connect(al_evento_area)
	guante.animation_finished.connect(al_terminar_caricia)


func _process(delta : float) -> void:
	if Engine.is_editor_hint() and posicion_hover:
		guante.position = posicion_hover.position


func al_entrar_mouse() -> void:
	mouse_encima = true
	if activo and not caricia_en_curso:
		mostrar_hover()


func al_salir_mouse() -> void:
	mouse_encima = false
	if not caricia_en_curso:
		desaparecer()


func al_evento_area(viewport : Node, evento : InputEvent, indice_forma : int) -> void:
	if not activo:
		return
	if evento is InputEventMouseButton and evento.button_index == MOUSE_BUTTON_LEFT and evento.pressed:
		reproducciones_restantes = repeticiones
		caricia_en_curso = true
		mover_guante(posicion_caricia.position)
		tween_movimiento.tween_callback(empezar_animacion)


func empezar_animacion() -> void:
	guante.play(&"acariciar")
	caricia_iniciada.emit()


func al_terminar_caricia() -> void:
	reproducciones_restantes -= 1
	if reproducciones_restantes > 0:
		guante.play(&"acariciar")
		return
	caricia_en_curso = false
	caricia_terminada.emit()
	if mouse_encima and activo:
		mostrar_hover()
	else:
		mover_guante(posicion_hover.position)
		desaparecer()


func mostrar_hover() -> void:
	guante.stop()
	guante.frame = 0
	if guante.visible and guante.modulate.a > 0.0:
		mover_guante(posicion_hover.position)
	else:
		guante.position = posicion_hover.position
	aparecer()


func mover_guante(destino : Vector2) -> void:
	if tween_movimiento:
		tween_movimiento.kill()
	tween_movimiento = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
	tween_movimiento.tween_property(guante, "position", destino, duracion_movimiento)


func aparecer() -> void:
	if tween_fade:
		tween_fade.kill()
	guante.visible = true
	tween_fade = create_tween()
	tween_fade.tween_property(guante, "modulate:a", 1.0, duracion_fade)


func desaparecer() -> void:
	if not guante.visible:
		return
	if tween_fade:
		tween_fade.kill()
	tween_fade = create_tween()
	tween_fade.tween_property(guante, "modulate:a", 0.0, duracion_fade)
	tween_fade.tween_callback(guante.hide)
