class_name GestorEconomia
extends RefCounted

signal monedas_cambiadas(nuevo_total: int, cambio: int)

static var _instancia: GestorEconomia
var _monedas: int = 200 # Saldo inicial por defecto para pruebas

static func get_instancia() -> GestorEconomia:
	if not _instancia:
		_instancia = GestorEconomia.new()
	return _instancia

func get_monedas() -> int:
	return _monedas

func tiene_suficiente(cantidad: int) -> bool:
	return _monedas >= cantidad

func agregar_monedas(cantidad: int) -> void:
	if cantidad <= 0:
		return
	_monedas += cantidad
	monedas_cambiadas.emit(_monedas, cantidad)

func gastar_monedas(cantidad: int) -> bool:
	if cantidad <= 0:
		return true
	if tiene_suficiente(cantidad):
		_monedas -= cantidad
		monedas_cambiadas.emit(_monedas, -cantidad)
		return true
	return false

func set_monedas(nueva_cantidad: int) -> void:
	var cambio = nueva_cantidad - _monedas
	_monedas = max(0, nueva_cantidad)
	monedas_cambiadas.emit(_monedas, cambio)
