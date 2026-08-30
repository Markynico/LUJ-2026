@tool
class_name Tarjeta
extends TextureRect

signal clickeada

##recurso de comida (PelotitaBase) o reliquia (Reliquia) que muestra la tarjeta
@export var recurso : Resource:
	set(valor):
		recurso = valor
		actualizar_tarjeta()

@export_group("Hover")
##si la tarjeta resalta el borde al pasar el mouse
@export var hover_activado : bool = true
##grosor del borde de hover en pixeles
@export var grosor_borde : int = 8
##alpha minimo de la pulsacion del borde
@export var pulso_minimo : float = 0.55
##segundos de cada ida o vuelta de la pulsacion
@export var pulso_duracion : float = 0.6

@export_group("Nodos")
@export var icono : TextureRect
@export var label_nombre : Label
@export var label_descripcion : RichTextLabel
@export var label_tipo : Label
@export var label_rareza : Label


var borde_hover : Panel
var tween_borde : Tween


func _ready() -> void:
	actualizar_tarjeta()
	if Engine.is_editor_hint():
		return
	crear_borde_hover()
	mouse_entered.connect(al_hover.bind(true))
	mouse_exited.connect(al_hover.bind(false))
	gui_input.connect(al_gui_input)


func crear_borde_hover() -> void:
	var estilo : StyleBoxFlat = StyleBoxFlat.new()
	borde_hover = Panel.new()
	estilo.draw_center = false
	estilo.set_border_width_all(grosor_borde)
	estilo.set_expand_margin_all(grosor_borde)
	borde_hover.add_theme_stylebox_override("panel", estilo)
	borde_hover.set_anchors_preset(Control.PRESET_FULL_RECT)
	borde_hover.mouse_filter = Control.MOUSE_FILTER_IGNORE
	borde_hover.modulate.a = 0.0
	add_child(borde_hover)
	actualizar_color_borde()


func actualizar_color_borde() -> void:
	var estilo : StyleBoxFlat
	if not borde_hover:
		return
	estilo = borde_hover.get_theme_stylebox("panel")
	if recurso and "rareza" in recurso:
		estilo.border_color = Rareza.color_de(recurso.rareza)
	else:
		estilo.border_color = Rareza.color_de(Rareza.Nivel.COMUN)


func al_gui_input(evento : InputEvent) -> void:
	if evento is InputEventMouseButton and evento.button_index == MOUSE_BUTTON_LEFT and evento.pressed:
		clickeada.emit()


func al_hover(entrando : bool) -> void:
	if entrando and not hover_activado:
		return
	mostrar_borde(entrando)


func mostrar_borde(encendido : bool) -> void:
	if not borde_hover:
		return
	if tween_borde:
		tween_borde.kill()
	tween_borde = borde_hover.create_tween()
	tween_borde.tween_property(borde_hover, "modulate:a", 1.0 if encendido else 0.0, 0.15)
	if encendido:
		tween_borde.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween_borde.tween_property(borde_hover, "modulate:a", pulso_minimo, pulso_duracion)
		tween_borde.tween_property(borde_hover, "modulate:a", 1.0, pulso_duracion)
		tween_borde.set_loops()


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
	if label_rareza and "rareza" in recurso:
		label_rareza.text = Rareza.nombre_de(recurso.rareza)
		label_rareza.add_theme_color_override("font_color", Rareza.color_de(recurso.rareza))
	actualizar_color_borde()


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
