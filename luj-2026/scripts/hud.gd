class_name HUD
extends Control

@onready var bolas_restantes: Label = %BolasRestantes
@onready var monedas_label: Label = %Monedas

@export var game_manager : GameManager
@export var textura_corazon : Texture2D = preload("res://iconos_custom/heart.svg")

@onready var contenedor_vidas : HBoxContainer = %ContenedorVidas
@onready var label_bolas : Label = %LabelBolas
@onready var barra_ovillos : ProgressBar = %BarraOvillos
@onready var label_ovillos : Label = %LabelOvillos
@onready var label_meta_badge : Label = %LabelMetaBadge
@onready var banner_notificacion : PanelContainer = %BannerNotificacion
@onready var label_notificacion : Label = %LabelNotificacion

var _corazones : Array[TextureRect] = []
var _tween_notif : Tween

func _ready() -> void:
	if not game_manager:
		game_manager = get_tree().root.find_child("GameManager", true, false) as GameManager
	if not game_manager and GameManager.instancia_actual:
		game_manager = GameManager.instancia_actual
	
	if banner_notificacion:
		banner_notificacion.visible = false
	
	if game_manager:
		game_manager.bola_usada.connect(actualizar_bolas_restantes)
		game_manager.vidas_cambiadas.connect(actualizar_vidas)
		game_manager.ovillos_actualizados.connect(actualizar_progreso_ovillos)
		game_manager.meta_alcanzada.connect(_on_meta_alcanzada)
		game_manager.nivel_completado.connect(_on_nivel_completado)
		game_manager.game_over.connect(_on_game_over)
		
		# Inicializar vistas
		actualizar_vidas(game_manager.vidas_actuales, game_manager.vidas_maximas)
		actualizar_bolas_restantes(game_manager.bolas_restantes)
	else:
		_crear_corazones(3, 3)

func _crear_corazones(vidas_actuales: int, vidas_max: int) -> void:
	for child in contenedor_vidas.get_children():
		child.queue_free()
	_corazones.clear()
	
	for i in range(vidas_max):
		var corazon = TextureRect.new()
		corazon.texture = textura_corazon
		corazon.custom_minimum_size = Vector2(28, 28)
		corazon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		corazon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		corazon.pivot_offset = Vector2(14, 14)
		
		if i < vidas_actuales:
			corazon.modulate = Color(1.0, 0.4, 0.5, 1.0)
		else:
			corazon.modulate = Color(0.3, 0.35, 0.45, 0.4)
		
		contenedor_vidas.add_child(corazon)
		_corazones.append(corazon)

func actualizar_vidas(vidas_actuales: int, vidas_max: int) -> void:
	if _corazones.size() != vidas_max:
		_crear_corazones(vidas_actuales, vidas_max)
		return
	
	for i in range(vidas_max):
		var corazon = _corazones[i]
		var estaba_activo = (corazon.modulate.a > 0.6)
		var ahora_activo = (i < vidas_actuales)
		
		if ahora_activo:
			corazon.modulate = Color(1.0, 0.4, 0.5, 1.0)
			if not estaba_activo:
				# Animación al ganar vida
				_animar_corazon(corazon, true)
		else:
			corazon.modulate = Color(0.3, 0.35, 0.45, 0.4)
			if estaba_activo:
				# Animación al perder vida
				_animar_corazon(corazon, false)

func _animar_corazon(corazon: TextureRect, ganado: bool) -> void:
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if ganado:
		corazon.scale = Vector2(1.5, 1.5)
		tween.tween_property(corazon, "scale", Vector2.ONE, 0.25)
	else:
		corazon.scale = Vector2(0.6, 0.6)
		tween.tween_property(corazon, "scale", Vector2.ONE, 0.2)
	actualizar_bolas_restantes(game_manager.bolas_restantes)
	game_manager.bola_usada.connect(actualizar_bolas_restantes)
	actualizar_monedas(Global.monedas)
	Global.monedas_cambiadas.connect(actualizar_monedas)

func actualizar_bolas_restantes(cantidad: int) -> void:
	if label_bolas:
		label_bolas.text = "Bolas restantes: %d" % cantidad
		var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		label_bolas.scale = Vector2(1.1, 1.1)
		label_bolas.pivot_offset = Vector2(0, label_bolas.size.y / 2.0)
		tween.tween_property(label_bolas, "scale", Vector2.ONE, 0.15)

func actualizar_progreso_ovillos(destruidos: int, requeridos: int, total: int, _porcentaje_actual: float) -> void:
	if barra_ovillos:
		barra_ovillos.max_value = max(total, 1)
		barra_ovillos.value = destruidos
	
	if label_ovillos:
		var pct_nivel = 0
		if game_manager:
			pct_nivel = int(game_manager.porcentaje_ovillos_requerido * 100.0)
		label_ovillos.text = "Ovillos: %d / %d  (Meta: %d | %d%%)" % [destruidos, total, requeridos, pct_nivel]
	
	if label_meta_badge:
		if destruidos >= requeridos:
			label_meta_badge.text = "✓ ¡META CUMPLIDA!"
			label_meta_badge.modulate = Color(0.35, 0.95, 0.55, 1.0)
		else:
			var faltan = max(0, requeridos - destruidos)
			label_meta_badge.text = "Faltan %d para ganar" % faltan
			label_meta_badge.modulate = Color(0.85, 0.88, 0.95, 0.8)

func _on_meta_alcanzada(es_meta: bool) -> void:
	if es_meta:
		mostrar_notificacion("¡Meta de nivel alcanzada! 🎉", Color(0.35, 0.95, 0.55))

func _on_nivel_completado(exito: bool) -> void:
	if exito:
		mostrar_notificacion("¡NIVEL SUPERADO! 🎉", Color(0.35, 0.95, 0.55))
	else:
		mostrar_notificacion("¡No alcanzaste la meta! Perdiste una vida 💔", Color(1.0, 0.4, 0.4))

func _on_game_over() -> void:
	mostrar_notificacion("GAME OVER 💀 Sin vidas restantes", Color(1.0, 0.25, 0.25))

func mostrar_notificacion(texto: String, color_texto: Color = Color.WHITE) -> void:
	if not banner_notificacion or not label_notificacion:
		return
	
	label_notificacion.text = texto
	label_notificacion.modulate = color_texto
	banner_notificacion.visible = true
	banner_notificacion.modulate.a = 0.0
	banner_notificacion.position.y = 80.0
	
	if _tween_notif and _tween_notif.is_valid():
		_tween_notif.kill()
	
	_tween_notif = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tween_notif.tween_property(banner_notificacion, "modulate:a", 1.0, 0.2)
	_tween_notif.parallel().tween_property(banner_notificacion, "position:y", 105.0, 0.25)
	_tween_notif.tween_interval(1.8)
	_tween_notif.chain().tween_property(banner_notificacion, "modulate:a", 0.0, 0.3)
	_tween_notif.finished.connect(func(): banner_notificacion.visible = false)
func actualizar_bolas_restantes(cantidad : int) -> void:
	bolas_restantes.text = "Bolas de pelo restantes: " + str(cantidad)

func actualizar_monedas(monedas : int):
	monedas_label.text = "Monedas: " + str(Global.monedas)
