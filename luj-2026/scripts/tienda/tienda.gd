class_name Tienda
extends Control

@export var escena_tarjeta: PackedScene = preload("res://escenas/componentes/tarjeta_tienda.tscn")
@export var items_en_oferta: Array[ItemTienda] = []
@export var cantidad_ofertas: int = 4
@export var costo_reroll: int = 20
@export var escena_siguiente: String = "res://escenas/menutest.tscn"

@onready var label_monedas: Label = %LabelMonedas
@onready var contenedor_tarjetas: HBoxContainer = %ContenedorTarjetas
@onready var boton_reroll: Button = %BotonReroll
@onready var boton_continuar: Button = %BotonContinuar
@onready var boton_dar_monedas: Button = %BotonDarMonedas
@onready var contenedor_inventario: HBoxContainer = %ContenedorInventario
@onready var label_inventario_vacio: Label = %LabelInventarioVacio

var _economia: GestorEconomia
var _inventario: InventarioJugador

func _ready() -> void:
	_economia = GestorEconomia.get_instancia()
	_inventario = InventarioJugador.get_instancia()
	
	_economia.monedas_cambiadas.connect(_on_monedas_cambiadas)
	_inventario.inventario_actualizado.connect(_actualizar_vista_inventario)
	
	boton_reroll.pressed.connect(_on_reroll_pressed)
	boton_continuar.pressed.connect(_on_continuar_pressed)
	if boton_dar_monedas:
		boton_dar_monedas.pressed.connect(_on_dar_monedas_pressed)
	
	_actualizar_display_monedas(_economia.get_monedas())
	_poblar_tienda()
	_actualizar_vista_inventario()

func _poblar_tienda() -> void:
	# Limpiar tarjetas anteriores
	for child in contenedor_tarjetas.get_children():
		child.queue_free()
	
	var catalogo = items_en_oferta
	if catalogo.is_empty():
		catalogo = CatalogoTienda.generar_catalogo_base()
	
	# Seleccionar items para mostrar
	var items_disponibles = catalogo.duplicate()
	items_disponibles.shuffle()
	
	var total_a_mostrar = min(cantidad_ofertas, items_disponibles.size())
	for i in range(total_a_mostrar):
		var item = items_disponibles[i]
		var tarjeta = escena_tarjeta.instantiate() as TarjetaTienda
		contenedor_tarjetas.add_child(tarjeta)
		tarjeta.configurar(item)
		tarjeta.compra_solicitada.connect(_on_item_comprado)
	
	_actualizar_estado_reroll()

func _actualizar_display_monedas(cantidad: int) -> void:
	label_monedas.text = "%d $" % cantidad

func _on_monedas_cambiadas(nuevo_total: int, _cambio: int) -> void:
	_actualizar_display_monedas(nuevo_total)
	_actualizar_estado_reroll()
	
	# Efecto punch / escala en el contador de monedas
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	label_monedas.scale = Vector2(1.2, 1.2)
	tween.tween_property(label_monedas, "scale", Vector2.ONE, 0.2)

func _actualizar_estado_reroll() -> void:
	boton_reroll.text = "↻  REROLL (%d $)" % costo_reroll
	boton_reroll.disabled = not _economia.tiene_suficiente(costo_reroll)

func _on_reroll_pressed() -> void:
	if _economia.gastar_monedas(costo_reroll):
		_poblar_tienda()

func _on_dar_monedas_pressed() -> void:
	_economia.agregar_monedas(50)

func _on_item_comprado(item: ItemTienda, _tarjeta: TarjetaTienda) -> void:
	print("Item comprado en la tienda: ", item.nombre)
	_actualizar_vista_inventario()

func _actualizar_vista_inventario() -> void:
	for child in contenedor_inventario.get_children():
		child.queue_free()
	
	var items = _inventario.get_items()
	var pelotitas = _inventario.get_pelotitas()
	
	var hay_items = (items.size() > 0 or pelotitas.size() > 0)
	if label_inventario_vacio:
		label_inventario_vacio.visible = not hay_items
	
	# Mostrar pelotitas desbloqueadas
	for p in pelotitas:
		var badge = _crear_badge_inventario(p.textura if p.textura else preload("res://iconos_custom/gobot.svg"), "Pelotita")
		contenedor_inventario.add_child(badge)
	
	# Mostrar otros items comprados
	for it in items:
		if not it.pelotita_recurso:
			var badge = _crear_badge_inventario(it.icono if it.icono else preload("res://iconos_custom/heart.svg"), it.nombre)
			contenedor_inventario.add_child(badge)

func _crear_badge_inventario(textura: Texture2D, tooltip: String) -> Control:
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(42, 42)
	panel.tooltip_text = tooltip
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.18, 0.22, 0.32, 0.9)
	style.border_color = Color(0.4, 0.5, 0.7, 0.8)
	style.set_border_width_all(1)
	style.set_corner_radius_all(10)
	style.content_margin_left = 4
	style.content_margin_top = 4
	style.content_margin_right = 4
	style.content_margin_bottom = 4
	panel.add_theme_stylebox_override("panel", style)
	
	var tex = TextureRect.new()
	tex.texture = textura
	tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	panel.add_child(tex)
	
	return panel

func _on_continuar_pressed() -> void:
	if ResourceLoader.exists(escena_siguiente):
		get_tree().change_scene_to_file(escena_siguiente)
	else:
		print("Escena siguiente no encontrada: ", escena_siguiente)
