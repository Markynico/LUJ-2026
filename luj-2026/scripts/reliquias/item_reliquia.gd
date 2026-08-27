@tool
class_name ItemReliquia
extends StaticBody2D

signal rota(reliquia : Reliquia)

##reliquia que se obtiene al romper este item
@export var reliquia : Reliquia:
	set(valor):
		if reliquia and reliquia.changed.is_connected(actualizar_icono):
			reliquia.changed.disconnect(actualizar_icono)
		reliquia = valor
		if reliquia:
			reliquia.changed.connect(actualizar_icono)
		actualizar_icono()
##diametro en pixeles al que se ajusta el icono, sin importar el tamaño de la textura
@export var tamaño_icono : float = 60.0:
	set(valor):
		tamaño_icono = max(valor, 1.0)
		actualizar_icono()
##golpes de bola de pelos necesarios para romperlo
@export var golpes_para_romper : int = 3
##cuanto se sacude el sprite al recibir un golpe
@export var fuerza_sacudida : float = 6.0
@export var sprite : Sprite2D
@export var colision : CollisionShape2D
@export var audio : AudioStreamPlayer

var golpes_recibidos : int = 0


func _ready() -> void:
	actualizar_icono()


func actualizar_icono() -> void:
	var lado : float
	if not sprite:
		return
	sprite.texture = reliquia.icono if reliquia else null
	if not sprite.texture:
		return
	lado = maxf(sprite.texture.get_width(), sprite.texture.get_height())
	if lado > 0.0:
		sprite.scale = Vector2.ONE * (tamaño_icono / lado)


func recibir_impacto(bola : BolaDePelos = null) -> void:
	if Engine.is_editor_hint():
		return
	golpes_recibidos += 1
	if golpes_recibidos >= golpes_para_romper:
		romper()
	else:
		sacudir()


func sacudir() -> void:
	var tween : Tween = create_tween()
	if not sprite:
		return
	tween.tween_property(sprite, "position", Vector2(fuerza_sacudida, 0), 0.05)
	tween.tween_property(sprite, "position", Vector2(-fuerza_sacudida, 0), 0.05)
	tween.tween_property(sprite, "position", Vector2.ZERO, 0.05)


func romper() -> void:
	if colision:
		colision.set_deferred("disabled", true)
	if sprite:
		sprite.hide()
	ReliquiasManager.obtener(reliquia)
	rota.emit(reliquia)
	if audio and audio.stream:
		audio.play()
		audio.finished.connect(queue_free)
	else:
		queue_free()
