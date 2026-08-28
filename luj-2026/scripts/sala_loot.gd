class_name SalaLoot
extends Control

signal continuar_pedido

##reliquias que pueden aparecer, se elige una al azar entre las que no se tienen
@export var reliquias_posibles : Array[Reliquia] = []
@export var icono : TextureRect
@export var label_nombre : Label
@export var label_descripcion : Label
@export var boton_aceptar : Button
@export var boton_rechazar : Button

var reliquia : Reliquia


func _ready() -> void:
	var candidatos : Array[Reliquia] = reliquias_posibles.filter(
		func(posible : Reliquia) -> bool: return posible != null and not ReliquiasManager.obtenidas.has(posible)
	)
	boton_aceptar.pressed.connect(aceptar)
	boton_rechazar.pressed.connect(rechazar)
	if candidatos.is_empty():
		continuar_pedido.emit.call_deferred()
		return
	if candidatos.size() > 1:
		candidatos.erase(ReliquiasManager.ultima_ofrecida)
	reliquia = candidatos.pick_random()
	ReliquiasManager.ultima_ofrecida = reliquia
	icono.texture = reliquia.icono
	label_nombre.text = reliquia.nombre
	label_descripcion.text = reliquia.descripcion


func aceptar() -> void:
	ReliquiasManager.obtener(reliquia)
	continuar_pedido.emit()


func rechazar() -> void:
	continuar_pedido.emit()
