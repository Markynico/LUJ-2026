class_name InventarioJugador
extends RefCounted

signal item_agregado(item: ItemTienda)
signal inventario_actualizado()

static var _instancia: InventarioJugador

var pelotitas_desbloqueadas: Array[PelotitaBase] = []
var items_comprados: Array[ItemTienda] = []
var pelotita_equipada: PelotitaBase

static func get_instancia() -> InventarioJugador:
	if not _instancia:
		_instancia = InventarioJugador.new()
		_instancia._cargar_items_iniciales()
	return _instancia

func _cargar_items_iniciales() -> void:
	# Cargar la pelotita básica por defecto si existe
	if ResourceLoader.exists("res://scripts/pelotitas_custom/pelotita1.tres"):
		var pelotita_inicial = load("res://scripts/pelotitas_custom/pelotita1.tres") as PelotitaBase
		if pelotita_inicial:
			pelotitas_desbloqueadas.append(pelotita_inicial)
			pelotita_equipada = pelotita_inicial

func agregar_item(item: ItemTienda) -> void:
	if not item:
		return
	
	items_comprados.append(item)
	
	if item.pelotita_recurso:
		if not pelotitas_desbloqueadas.has(item.pelotita_recurso):
			pelotitas_desbloqueadas.append(item.pelotita_recurso)
	
	item_agregado.emit(item)
	inventario_actualizado.emit()

func posee_item(item: ItemTienda) -> bool:
	if not item:
		return false
	if item.pelotita_recurso and pelotitas_desbloqueadas.has(item.pelotita_recurso):
		return true
	for comprado in items_comprados:
		if comprado.id == item.id and not item.id.is_empty():
			return true
	return false

func get_items() -> Array[ItemTienda]:
	return items_comprados

func get_pelotitas() -> Array[PelotitaBase]:
	return pelotitas_desbloqueadas
