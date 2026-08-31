extends CanvasLayer

##segundos que la notificacion queda visible
@export var duracion_visible : float = 3.5
##segundos de la animacion de entrada y salida
@export var duracion_animacion : float = 0.4
##distancia desde el borde superior derecho
@export var margen : Vector2 = Vector2(40, 40)
##alto del icono de la reliquia
@export var alto_icono : float = 56.0
##tamaño de fuente del titulo
@export var tamaño_titulo : int = 26
##tamaño de fuente del nombre de la reliquia
@export var tamaño_nombre : int = 30
##grosor del contorno del nombre de la reliquia
@export var grosor_contorno_nombre : int = 7
##color del contorno del nombre de la reliquia
@export var color_contorno_nombre : Color = Color.BLACK
##theme del que se toma el estilo de boton para el panel
@export var theme_estilo : Theme = preload("uid://bjkvjfhj8dr8y")
##fuente del titulo de la notificacion
@export var fuente_titulo : Font = preload("uid://dwg47e0trev3j")

var cola : Array[Reliquia] = []
var mostrando : bool = false


func mostrar_desbloqueo(reliquia : Reliquia) -> void:
	cola.append(reliquia)
	if not mostrando:
		mostrar_siguiente()


func mostrar_siguiente() -> void:
	var reliquia : Reliquia
	var panel : PanelContainer
	var tween : Tween
	var destino_x : float
	if cola.is_empty():
		mostrando = false
		return
	mostrando = true
	reliquia = cola.pop_front()
	panel = crear_panel(reliquia)
	panel.hide()
	add_child(panel)
	await get_tree().process_frame
	destino_x = get_viewport().get_visible_rect().size.x - panel.size.x - margen.x
	panel.position = Vector2(get_viewport().get_visible_rect().size.x, margen.y)
	panel.show()
	tween = create_tween()
	tween.tween_property(panel, "position:x", destino_x, duracion_animacion).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.tween_interval(duracion_visible)
	tween.tween_property(panel, "position:x", get_viewport().get_visible_rect().size.x, duracion_animacion).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	tween.tween_callback(panel.queue_free)
	tween.tween_callback(mostrar_siguiente)


func crear_panel(reliquia : Reliquia) -> PanelContainer:
	var panel : PanelContainer = PanelContainer.new()
	var contenido : VBoxContainer = VBoxContainer.new()
	var titulo : Label = Label.new()
	var fila : HBoxContainer = HBoxContainer.new()
	var icono : TextureRect = TextureRect.new()
	var nombre : Label = Label.new()
	panel.theme = theme_estilo
	panel.add_theme_stylebox_override("panel", theme_estilo.get_stylebox("normal", "Button"))
	titulo.text = "¡Reliquia desbloqueada!"
	titulo.add_theme_font_override("font", fuente_titulo)
	titulo.add_theme_font_size_override("font_size", tamaño_titulo)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	fila.add_theme_constant_override("separation", 16)
	fila.alignment = BoxContainer.ALIGNMENT_CENTER
	if reliquia.icono:
		icono.texture = reliquia.icono
		icono.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icono.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icono.custom_minimum_size = Vector2(reliquia.icono.get_width() * alto_icono / reliquia.icono.get_height(), alto_icono)
	nombre.text = reliquia.nombre
	nombre.add_theme_font_size_override("font_size", tamaño_nombre)
	nombre.add_theme_color_override("font_color", Rareza.color_de(reliquia.rareza))
	nombre.add_theme_constant_override("outline_size", grosor_contorno_nombre)
	nombre.add_theme_color_override("font_outline_color", color_contorno_nombre)
	nombre.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	fila.add_child(icono)
	fila.add_child(nombre)
	contenido.add_child(titulo)
	contenido.add_child(fila)
	panel.add_child(contenido)
	return panel
