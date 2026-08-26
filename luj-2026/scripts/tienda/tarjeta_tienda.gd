class_name TarjetaTienda
extends PanelContainer

signal compra_solicitada(item: ItemTienda, tarjeta: TarjetaTienda)

@export var item_data: ItemTienda

@onready var label_nombre: Label = %LabelNombre
@onready var label_tipo: Label = %LabelTipo
@onready var label_rareza: Label = %LabelRareza
@onready var panel_badge_rareza: PanelContainer = %PanelBadgeRareza
@onready var texture_icono: TextureRect = %TextureIcono
@onready var label_descripcion: Label = %LabelDescripcion
@onready var boton_comprar: Button = %BotonComprar
@onready var audio_compra: AudioStreamPlayer = %AudioCompra

var economia: GestorEconomia
var inventario: InventarioJugador
var _ya_comprado: bool = false
var _tween_hover: Tween

func _ready() -> void:
	economia = GestorEconomia.get_instancia()
	inventario = InventarioJugador.get_instancia()
	
	economia.monedas_cambiadas.connect(al_cambiar_monedas)
	boton_comprar.pressed.connect(_on_boton_comprar_pressed)
	
	# Efectos de hover en la tarjeta entera
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	pivot_offset = size / 2.0
	resized.connect(func(): pivot_offset = size / 2.0)
	
	if item_data:
		configurar(item_data)

func configurar(item: ItemTienda) -> void:
	item_data = item
	if not item_data:
		return
	
	label_nombre.text = item_data.nombre
	label_descripcion.text = item_data.descripcion
	
	# Icono
	if item_data.icono:
		texture_icono.texture = item_data.icono
	elif item_data.pelotita_recurso and item_data.pelotita_recurso.textura:
		texture_icono.texture = item_data.pelotita_recurso.textura
	
	# Tipo
	match item_data.tipo:
		ItemTienda.TipoItem.PELOTITA:
			label_tipo.text = "PELOTITA"
		ItemTienda.TipoItem.MEJORA_PASIVA:
			label_tipo.text = "PASIVA"
		ItemTienda.TipoItem.CONSUMIBLE:
			label_tipo.text = "CONSUMIBLE"
	
	# Rareza y colores
	var color_rareza = ItemTienda.get_color_rareza(item_data.rareza)
	label_rareza.text = ItemTienda.get_nombre_rareza(item_data.rareza)
	label_rareza.modulate = color_rareza
	
	# Estilizar el borde de la tarjeta con el color de la rareza
	_aplicar_estilo_rareza(color_rareza)
	
	# Verificar si ya está comprado
	_ya_comprado = inventario.posee_item(item_data)
	actualizar_estado_compra()

func _aplicar_estilo_rareza(color_rareza: Color) -> void:
	var style = get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	if style:
		style.border_color = color_rareza
		style.shadow_color = Color(color_rareza.r, color_rareza.g, color_rareza.b, 0.25)
		add_theme_stylebox_override("panel", style)

func actualizar_estado_compra() -> void:
	if not item_data:
		return
	
	if _ya_comprado:
		boton_comprar.text = "✓ COMPRADO"
		boton_comprar.disabled = true
		modulate = Color(0.7, 0.7, 0.7, 0.85)
		return
	
	var tiene_dinero = economia.tiene_suficiente(item_data.precio)
	boton_comprar.text = "%d   COMPRAR" % item_data.precio
	boton_comprar.disabled = not tiene_dinero
	
	if tiene_dinero:
		boton_comprar.modulate = Color.WHITE
	else:
		boton_comprar.modulate = Color(1.0, 0.65, 0.65) # Tinte rojizo por falta de fondos

func _on_boton_comprar_pressed() -> void:
	if _ya_comprado or not item_data:
		return
	
	if economia.gastar_monedas(item_data.precio):
		_ya_comprado = true
		inventario.agregar_item(item_data)
		actualizar_estado_compra()
		compra_solicitada.emit(item_data, self)
		
		# Animación de éxito
		_animar_compra_exitosa()
		if audio_compra:
			audio_compra.pitch_scale = randf_range(1.1, 1.25)
			audio_compra.play()

func _animar_compra_exitosa() -> void:
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.15)
	tween.chain().tween_property(self, "scale", Vector2.ONE, 0.15)

func al_cambiar_monedas(_nuevo_total: int, cambio: int) -> void:
	actualizar_estado_compra()

func _on_mouse_entered() -> void:
	if _tween_hover and _tween_hover.is_valid():
		_tween_hover.kill()
	_tween_hover = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween_hover.tween_property(self, "scale", Vector2(1.04, 1.04), 0.15)
	#_tween_hover.tween_property(self, "position:y", position.y - 6.0, 0.15)

func _on_mouse_exited() -> void:
	if _tween_hover and _tween_hover.is_valid():
		_tween_hover.kill()
	_tween_hover = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween_hover.tween_property(self, "scale", Vector2.ONE, 0.15)
	#_tween_hover.tween_property(self, "position:y", position.y + 6.0, 0.15)
