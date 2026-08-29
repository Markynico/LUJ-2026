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
@export var label_tipo : Label


func _ready() -> void:
	actualizar_tarjeta()


func actualizar_tarjeta() -> void:
	if not recurso:
		return
	if label_nombre and "nombre" in recurso:
		label_nombre.text = recurso.nombre
	if label_descripcion and "descripcion" in recurso:
		label_descripcion.text = Resaltador.formatear(recurso.descripcion)
	if icono:
		icono.texture = obtener_icono()
	if label_tipo:
		label_tipo.text = obtener_tipo()


func obtener_tipo() -> String:
	if recurso is Reliquia:
		return "Reliquia"
	if recurso is PelotitaBase:
		return "Comida"
	return ""


func obtener_icono() -> Texture2D:
	if "icono" in recurso and recurso.icono:
		return recurso.icono
	if "imagen_comida_asociada" in recurso and recurso.imagen_comida_asociada:
		return recurso.imagen_comida_asociada
	if "textura" in recurso and recurso.textura:
		return recurso.textura
	return null
