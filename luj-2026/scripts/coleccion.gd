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
	if "condicion_desbloqueo" in item and not Progreso.esta_desbloqueada(item):
		bloquear_tarjeta(envoltura, tarjeta, item)
	else:
		tarjeta.clickeada.connect(al_click_tarjeta.bind(tarjeta))


func bloquear_tarjeta(envoltura : Control, tarjeta : Tarjeta, reliquia : Resource) -> void:
	var etiqueta : Label = Label.new()
	tarjeta.modulate = color_bloqueada
	tarjeta.hover_activado = false
	if tarjeta.icono:
		tarjeta.icono.self_modulate = Color.BLACK
	etiqueta.text = "%s\n%d/%d" % [Progreso.descripcion_condicion(reliquia), Progreso.valor_condicion(reliquia), reliquia.cantidad_desbloqueo]
	etiqueta.add_theme_font_override("font", fuente_condicion)
	etiqueta.add_theme_font_size_override("font_size", tamaño_fuente_condicion)
	etiqueta.add_theme_color_override("font_color", Color.WHITE)
	etiqueta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	etiqueta.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	etiqueta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	etiqueta.set_anchors_preset(Control.PRESET_FULL_RECT)
	envoltura.add_child(etiqueta)


func al_click_tarjeta(tarjeta : Tarjeta) -> void:
	foco.abrir(tarjeta)


func volver_al_menu() -> void:
	if cerrada.get_connections().is_empty():
		Transicion.cambiar_escena(escena_menu)
	else:
		cerrada.emit()
