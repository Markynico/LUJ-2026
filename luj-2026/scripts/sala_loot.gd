class_name SalaLoot
extends Control

signal continuar_pedido

##reliquias que pueden aparecer, se elige una al azar entre las que no se tienen
@export var reliquias_posibles : Array[Reliquia] = []
@export var tarjeta : Tarjeta
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
	if GameManager.instancia_actual:
		candidatos = GameManager.filtrar_por_rareza(candidatos, GameManager.instancia_actual.sortear_rareza())
	reliquia = candidatos.pick_random()
	ReliquiasManager.ultima_ofrecida = reliquia
	tarjeta.recurso = reliquia


func aceptar() -> void:
	ReliquiasManager.obtener(reliquia)
	continuar_pedido.emit()


func rechazar() -> void:
	continuar_pedido.emit()
