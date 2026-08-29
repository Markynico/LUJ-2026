@tool
class_name Tarjeta
extends TextureRect

##recurso de comida (PelotitaBase) o reliquia (Reliquia) que muestra la tarjeta
@export var recurso : Resource:
	set(valor):
		recurso = valor
		actualizar_tarjeta()

@export_group("Nodos")
@export var icono : TextureRect
@export var label_nombre : Label
@export var label_descripcion : RichTextLabel


func _ready() -> void:
	actualizar_tarjeta()


func actualizar_tarjeta() -> void:
	if not recurso:
		return
	if label_nombre and "nombre" in recurso:
		label_nombre.text = recurso.nombre
	if label_descripcion and "descripcion" in recurso:
		label_descripcion.text = recurso.descripcion
	if icono:
		icono.texture = obtener_icono()


func obtener_icono() -> Texture2D:
	if "icono" in recurso and recurso.icono:
		return recurso.icono
	if "imagen_comida_asociada" in recurso and recurso.imagen_comida_asociada:
		return recurso.imagen_comida_asociada
	if "textura" in recurso and recurso.textura:
		return recurso.textura
	return null
