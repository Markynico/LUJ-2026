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
##segundos del fade in y out cuando se usa como tarjeta de hover
@export var duracion_fade : float = 0.15

@export_group("Boton de precio")
##icono de moneda del boton de precio
@export var icono_moneda : Texture2D = preload("uid://cmgxgm42kfbke")
##fuente del boton de precio
@export var fuente_boton : FontFile = preload("uid://dwg47e0trev3j")
##tamaño de fuente del boton de precio
@export var tamaño_fuente_boton : int = 22
##alto del icono de moneda
@export var tamaño_icono : int = 38
##relleno interno del boton (horizontal, vertical)
@export var relleno_boton : Vector2 = Vector2(16, 8)
##tamaño de fuente del boton de compra en el foco
@export var tamaño_fuente_foco : int = 30
##ancho maximo del icono de moneda en el foco
@export var tamaño_icono_foco : int = 60
##relleno interno del boton de compra en el foco
@export var relleno_foco : Vector2 = Vector2(30, 16)
##margen del boton con los bordes de la tarjeta
@export var margen_boton : int = 24
##color del boton cuando alcanza la plata
@export var color_alcanza : Color = Color(0.0988, 0.76, 0.0988)
##color del boton cuando no alcanza la plata
@export var color_no_alcanza : Color = Color(0.85, 0.0, 0.0)

@export_group("Nodos")
@export var icono : TextureRect
@export var label_nombre : Label
@export var label_descripcion : RichTextLabel
@export var label_tipo : Label
@export var label_rareza : Label

@export_group("Ajuste de fuentes")
##tamaño minimo al que se achica la descripcion para entrar sin scroll
@export var tamaño_minimo_descripcion : int = 12
##tamaño minimo al que se achica el nombre para no tocar los bordes
@export var tamaño_minimo_nombre : int = 24
##margen lateral minimo del nombre con el borde de la tarjeta
@export var margen_nombre : float = 20.0
##tamaño minimo al que se achica la rareza para no pisar el sello
@export var tamaño_minimo_rareza : int = 14
##ancho maximo del texto de rareza antes de achicarse, para no pisar el sello
@export var ancho_maximo_rareza : float = 147.0

var tamaño_base_descripcion : int = 0
var tamaño_base_nombre : int = 0
var tamaño_base_rareza : int = 0


var borde_hover : Panel
var tween_borde : Tween
var tween_fade : Tween
var boton_precio : Button
var precio_actual : int = 0


func _ready() -> void:
	actualizar_tarjeta()
	if label_descripcion:
		label_descripcion.resized.connect(ajustar_fuente_descripcion)
	if label_nombre:
		label_nombre.resized.connect(ajustar_fuente_nombre)
	if label_rareza:
		label_rareza.resized.connect(ajustar_fuente_rareza)
	if Engine.is_editor_hint():
		return
	crear_borde_hover()
	if label_descripcion:
		Resaltador.conectar_hover(label_descripcion)
	mouse_entered.connect(al_hover.bind(true))
	mouse_exited.connect(al_hover.bind(false))
	gui_input.connect(al_gui_input)


func aparecer() -> void:
	if tween_fade:
		tween_fade.kill()
	if not visible:
		modulate.a = 0.0
	show()
	tween_fade = create_tween()
	tween_fade.tween_property(self, "modulate:a", 1.0, duracion_fade)


func desaparecer() -> void:
	if not visible:
		return
	if tween_fade:
		tween_fade.kill()
	tween_fade = create_tween()
	tween_fade.tween_property(self, "modulate:a", 0.0, duracion_fade)
	tween_fade.tween_callback(hide)


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
		ajustar_fuente_nombre.call_deferred()
	if label_descripcion and "descripcion" in recurso:
		if recurso.has_method("descripcion_para_mostrar"):
			label_descripcion.text = Resaltador.formatear(recurso.descripcion_para_mostrar())
		else:
			label_descripcion.text = Resaltador.formatear(recurso.descripcion)
		ajustar_fuente_descripcion.call_deferred()
	if icono:
		icono.texture = obtener_icono()
	if label_tipo:
		label_tipo.text = obtener_tipo()
	if label_rareza and "rareza" in recurso:
		label_rareza.text = Rareza.nombre_de(recurso.rareza)
		label_rareza.add_theme_color_override("font_color", Rareza.color_de(recurso.rareza))
		ajustar_fuente_rareza.call_deferred()
	actualizar_color_borde()


func ajustar_fuente_descripcion() -> void:
	var tamaño : int
	if not label_descripcion or not is_inside_tree():
		return
	if tamaño_base_descripcion == 0:
		tamaño_base_descripcion = label_descripcion.get_theme_font_size("normal_font_size")
	tamaño = tamaño_base_descripcion
	label_descripcion.add_theme_font_size_override("normal_font_size", tamaño)
	while tamaño > tamaño_minimo_descripcion and label_descripcion.get_content_height() > label_descripcion.size.y:
		tamaño -= 1
		label_descripcion.add_theme_font_size_override("normal_font_size", tamaño)


func ajustar_fuente_nombre() -> void:
	var fuente : Font
	var tamaño : int
	if not label_nombre or not is_inside_tree():
		return
	if tamaño_base_nombre == 0:
		tamaño_base_nombre = label_nombre.get_theme_font_size("font_size")
	fuente = label_nombre.get_theme_font("font")
	tamaño = tamaño_base_nombre
	while tamaño > tamaño_minimo_nombre and fuente.get_string_size(label_nombre.text, HORIZONTAL_ALIGNMENT_CENTER, -1, tamaño).x > label_nombre.size.x - margen_nombre * 2.0:
		tamaño -= 1
	label_nombre.add_theme_font_size_override("font_size", tamaño)


func ajustar_fuente_rareza() -> void:
	var fuente : Font
	var tamaño : int
	if not label_rareza or not is_inside_tree():
		return
	if tamaño_base_rareza == 0:
		tamaño_base_rareza = label_rareza.get_theme_font_size("font_size")
	fuente = label_rareza.get_theme_font("font")
	tamaño = tamaño_base_rareza
	while tamaño > tamaño_minimo_rareza and fuente.get_string_size(label_rareza.text, HORIZONTAL_ALIGNMENT_RIGHT, -1, tamaño).x > ancho_maximo_rareza:
		tamaño -= 1
	label_rareza.add_theme_font_size_override("font_size", tamaño)


func obtener_tipo() -> String:
	if recurso is Reliquia:
		return "Reliquia"
	if recurso is PelotitaBase:
		return "Comida"
	if recurso is OvilloBase:
		return "Ovillo"
	return ""


func obtener_icono() -> Texture2D:
	if "icono" in recurso and recurso.icono:
		return recurso.icono
	if "imagen_comida_asociada" in recurso and recurso.imagen_comida_asociada:
		return recurso.imagen_comida_asociada
	if "textura" in recurso and recurso.textura:
		return recurso.textura
	if "sprite" in recurso and recurso.sprite:
		return recurso.sprite
	return null


func mostrar_boton_precio(precio : int) -> Button:
	var margen : MarginContainer = MarginContainer.new()
	precio_actual = precio
	boton_precio = Button.new()
	margen.set_anchors_preset(Control.PRESET_FULL_RECT)
	margen.add_theme_constant_override("margin_bottom", margen_boton)
	boton_precio.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	boton_precio.size_flags_vertical = Control.SIZE_SHRINK_END
	margen.add_child(boton_precio)
	add_child(margen)
	estilizar_boton_precio(boton_precio, precio)
	Global.monedas_cambiadas.connect(al_cambiar_monedas)
	return boton_precio


func estilizar_boton_precio(boton : Button, precio : int, en_foco : bool = false) -> void:
	var relleno : Vector2 = relleno_foco if en_foco else relleno_boton
	boton.text = str(precio)
	boton.icon = icono_moneda
	boton.alignment = HORIZONTAL_ALIGNMENT_LEFT
	boton.add_theme_font_override("font", fuente_boton)
	boton.add_theme_font_size_override("font_size", tamaño_fuente_foco if en_foco else tamaño_fuente_boton)
	boton.add_theme_constant_override("icon_max_width", tamaño_icono_foco if en_foco else tamaño_icono)
	for nombre in ["font_color", "font_hover_color", "font_pressed_color", "font_hover_pressed_color", "font_focus_color"]:
		boton.add_theme_color_override(nombre, Color.WHITE)
	for estado in ["normal", "hover", "pressed", "disabled"]:
		achicar_estilo(boton, estado, relleno)
	colorear_por_monedas(boton, precio)


func achicar_estilo(boton : Button, estado : String, relleno : Vector2) -> void:
	var estilo : StyleBoxFlat = boton.get_theme_stylebox(estado).duplicate()
	estilo.expand_margin_left = 0.0
	estilo.expand_margin_top = 0.0
	estilo.expand_margin_right = 0.0
	estilo.expand_margin_bottom = 0.0
	estilo.content_margin_left = relleno.x
	estilo.content_margin_top = relleno.y
	estilo.content_margin_right = relleno.x
	estilo.content_margin_bottom = relleno.y
	estilo.set_meta("bg_original", estilo.bg_color)
	estilo.set_meta("borde_original", estilo.border_color)
	boton.add_theme_stylebox_override(estado, estilo)


func colorear_por_monedas(boton : Button, precio : int) -> void:
	var alcanza : bool = Global.monedas >= precio
	if not boton.visible:
		return
	boton.disabled = not alcanza
	for estado in ["normal", "hover", "pressed"]:
		var estilo : StyleBoxFlat = boton.get_theme_stylebox(estado)
		if estilo and estilo.has_meta("bg_original"):
			estilo.bg_color = estilo.get_meta("bg_original").lerp(color_alcanza, 0.6)
			estilo.border_color = estilo.get_meta("borde_original").lerp(color_alcanza, 0.6).darkened(0.3)


func al_cambiar_monedas(monedas : int) -> void:
	if boton_precio and boton_precio.visible:
		colorear_por_monedas(boton_precio, precio_actual)
