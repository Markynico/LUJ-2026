class_name Coleccion
extends Control

signal cerrada

##reliquias que muestra la coleccion
@export var pool_reliquias : Array[Reliquia] = []
##comidas que muestra la coleccion
@export var pool_comidas : Array[PelotitaBase] = []
##escala de las tarjetas en la grilla
@export var escala_tarjeta : float = 0.5
##tamaño base de la tarjeta
@export var tamaño_tarjeta : Vector2 = Vector2(500, 600)
##escena de la tarjeta
@export var escena_tarjeta : PackedScene = preload("uid://u6k76f6lyw8y")
##escena del menu a la que vuelve el boton
@export_file("*.tscn") var escena_menu : String = "uid://c30ry4xehty4"
##color con el que se oscurecen las tarjetas bloqueadas
@export var color_bloqueada : Color = Color(0.35, 0.35, 0.35)
##tamaño de fuente del texto de condicion de desbloqueo
@export var tamaño_fuente_condicion : int = 34
##tamaño minimo al que se achica el texto de desbloqueo para que entre en la tarjeta
@export var tamaño_fuente_condicion_minimo : int = 12
##margen en pixeles entre el texto de desbloqueo y el borde de la tarjeta, ya escalada
@export var margen_texto_condicion : float = 24.0
##fuente del texto de condicion de desbloqueo
@export var fuente_condicion : Font = preload("uid://dwg47e0trev3j")

@export_group("Nodos")
@export var grilla_reliquias : GridContainer
@export var grilla_comidas : GridContainer
@export var boton_volver : Button
@export var foco : FocoTarjetas


func _ready() -> void:
	boton_volver.pressed.connect(volver_al_menu)
	poblar_grilla(grilla_reliquias, pool_reliquias)
	poblar_grilla(grilla_comidas, pool_comidas)


func poblar_grilla(grilla : GridContainer, items : Array) -> void:
	var ordenados : Array = items.filter(func(item : Resource) -> bool: return item != null)
	ordenados.sort_custom(func(a : Resource, b : Resource) -> bool: return rareza_de(a) < rareza_de(b))
	for item in ordenados:
		crear_tarjeta(grilla, item)


func rareza_de(item : Resource) -> int:
	if "rareza" in item:
		return item.rareza
	return 0


func crear_tarjeta(grilla : GridContainer, item : Resource) -> void:
	var envoltura : Control = Control.new()
	var tarjeta : Tarjeta = escena_tarjeta.instantiate()
	envoltura.custom_minimum_size = tamaño_tarjeta * escala_tarjeta
	tarjeta.size = tamaño_tarjeta
	tarjeta.scale = Vector2.ONE * escala_tarjeta
	tarjeta.recurso = item
	envoltura.add_child(tarjeta)
	grilla.add_child(envoltura)
	if Progreso.tiene_condiciones(item) and not Progreso.esta_desbloqueada(item):
		bloquear_tarjeta(envoltura, tarjeta, item)
	else:
		tarjeta.clickeada.connect(al_click_tarjeta.bind(tarjeta))


func bloquear_tarjeta(envoltura : Control, tarjeta : Tarjeta, reliquia : Resource) -> void:
	var etiqueta : RichTextLabel = RichTextLabel.new()
	var texto : String = "%s\n%s" % [Progreso.descripcion_condiciones(reliquia), Progreso.contadores_condiciones(reliquia)]
	tarjeta.modulate = color_bloqueada
	tarjeta.hover_activado = false
	if tarjeta.icono:
		tarjeta.icono.self_modulate = Color.BLACK
	etiqueta.bbcode_enabled = true
	etiqueta.scroll_active = false
	etiqueta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	etiqueta.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	etiqueta.add_theme_font_override("normal_font", fuente_condicion)
	etiqueta.add_theme_font_size_override("normal_font_size", tamaño_fuente_que_entra(texto_plano(texto), envoltura.custom_minimum_size - Vector2.ONE * margen_texto_condicion * 2.0))
	etiqueta.add_theme_color_override("default_color", Color.WHITE)
	etiqueta.text = "[center]" + Resaltador.formatear(texto) + "[/center]"
	etiqueta.set_anchors_preset(Control.PRESET_FULL_RECT)
	etiqueta.offset_left = margen_texto_condicion
	etiqueta.offset_top = margen_texto_condicion
	etiqueta.offset_right = -margen_texto_condicion
	etiqueta.offset_bottom = -margen_texto_condicion
	envoltura.add_child(etiqueta)


func texto_plano(texto : String) -> String:
	var regex : RegEx = RegEx.new()
	regex.compile("\\{[^}]*\\}")
	return regex.sub(texto, "OO", true)


func tamaño_fuente_que_entra(texto : String, espacio : Vector2) -> int:
	var tamaño : int = tamaño_fuente_condicion
	var medida : Vector2
	while tamaño > tamaño_fuente_condicion_minimo:
		medida = fuente_condicion.get_multiline_string_size(texto, HORIZONTAL_ALIGNMENT_CENTER, espacio.x, tamaño, -1, TextServer.BREAK_WORD_BOUND | TextServer.BREAK_MANDATORY)
		if medida.y <= espacio.y and medida.x <= espacio.x:
			break
		tamaño -= 1
	return tamaño


func al_click_tarjeta(tarjeta : Tarjeta) -> void:
	foco.abrir(tarjeta)


func volver_al_menu() -> void:
	if cerrada.get_connections().is_empty():
		Transicion.cambiar_escena(escena_menu)
	else:
		cerrada.emit()
