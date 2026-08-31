class_name HUD
extends Control

@export var game_manager : GameManager
@export var textura_corazon : Texture2D = preload("res://iconos_custom/heart.svg")
##shader que dibuja el contorno del icono de dificultad siguiendo el sprite
@export var shader_contorno : Shader = preload("res://scripts/shaders/contorno_seleccion.gdshader")
##grosor del contorno del icono de dificultad
@export var grosor_contorno_dificultad : float = 5.0
##color de la barra de progreso mientras no se llego al objetivo
@export var color_barra_falta : Color = Color(0.8, 0.18, 0.15)
##color de la barra de progreso al cumplir el objetivo, pulsa hacia mas claro
@export var color_barra_meta : Color = Color(0.2, 0.75, 0.48)

@onready var contenedor_vidas : HBoxContainer = %ContenedorVidas
@onready var label_bolas : Label = %LabelBolas
@onready var barra_ovillos : ProgressBar = %BarraOvillos
@onready var label_ovillos : Label = %LabelOvillos
@onready var label_salas : Label = %LabelSalas
@onready var icono_dificultad : TextureRect = %IconoDificultad
@onready var bolas_restantes_label : Label = %BolasRestantes if has_node("%BolasRestantes") else null
@onready var monedas_label : Label = %Monedas if has_node("%Monedas") else null

var corazones : Array[TextureRect] = []
var tween_barra : Tween
var meta_barra : int = -1

func _ready() -> void:
	if not game_manager:
		game_manager = get_tree().root.find_child("GameManager", true, false) as GameManager
	if not game_manager and GameManager.instancia_actual:
		game_manager = GameManager.instancia_actual
	
	# Monedas globales
	actualizar_monedas(Global.monedas)
	Global.monedas_cambiadas.connect(actualizar_monedas)
	
	if game_manager:
		game_manager.bola_usada.connect(actualizar_bolas_restantes)
		game_manager.vidas_cambiadas.connect(actualizar_vidas)
		game_manager.puntos_actualizados.connect(actualizar_progreso_ovillos)
		game_manager.nivel_completado.connect(al_completar_nivel)

		# Inicializar vistas
		actualizar_vidas(game_manager.vidas_actuales, game_manager.vidas_maximas)
		actualizar_bolas_restantes(game_manager.bolas_restantes)
		actualizar_salas()
	else:
		crear_corazones(3, 3)

func crear_corazones(vidas_actuales: int, vidas_max: int) -> void:
	if not contenedor_vidas:
		return
	for child in contenedor_vidas.get_children():
		child.queue_free()
	corazones.clear()
	
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
		corazones.append(corazon)

func actualizar_vidas(vidas_actuales: int, vidas_max: int) -> void:
	if corazones.size() != vidas_max:
		crear_corazones(vidas_actuales, vidas_max)
		return
	
	for i in range(vidas_max):
		var corazon = corazones[i]
		var estaba_activo = (corazon.modulate.a > 0.6)
		var ahora_activo = (i < vidas_actuales)
		
		if ahora_activo:
			corazon.modulate = Color(1.0, 0.4, 0.5, 1.0)
			if not estaba_activo:
				# Animación al ganar vida
				animar_corazon(corazon, true)
		else:
			corazon.modulate = Color(0.3, 0.35, 0.45, 0.4)
			if estaba_activo:
				# Animación al perder vida
				animar_corazon(corazon, false)

func animar_corazon(corazon: TextureRect, ganado: bool) -> void:
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if ganado:
		corazon.scale = Vector2(1.5, 1.5)
		tween.tween_property(corazon, "scale", Vector2.ONE, 0.25)
	else:
		corazon.scale = Vector2(0.6, 0.6)
		tween.tween_property(corazon, "scale", Vector2.ONE, 0.2)

func actualizar_bolas_restantes(cantidad: int) -> void:
	if label_bolas:
		label_bolas.text = "Bolas restantes: %d" % cantidad
		var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		label_bolas.scale = Vector2(1.1, 1.1)
		label_bolas.pivot_offset = Vector2(0, label_bolas.size.y / 2.0)
		tween.tween_property(label_bolas, "scale", Vector2.ONE, 0.15)
	
	if bolas_restantes_label:
		bolas_restantes_label.text = "Bolas de pelo restantes: " + str(cantidad)

func actualizar_monedas(monedas: int) -> void:
	if monedas_label:
		monedas_label.text = str(monedas)

func actualizar_progreso_ovillos(obtenidos: int, requeridos: int, total: int, porcentaje_actual: float) -> void:
	if barra_ovillos:
		barra_ovillos.max_value = max(requeridos, 1)
		barra_ovillos.value = min(obtenidos, requeridos)
		colorear_barra(obtenidos >= requeridos)

	if label_ovillos:
		label_ovillos.text = "Puntos: %d / %d" % [obtenidos, requeridos]

	actualizar_salas()

func colorear_barra(meta_cumplida: bool) -> void:
	var relleno : StyleBoxFlat = barra_ovillos.get_theme_stylebox("fill")
	if int(meta_cumplida) == meta_barra:
		return
	meta_barra = int(meta_cumplida)
	if tween_barra and tween_barra.is_valid():
		tween_barra.kill()
	if meta_cumplida:
		relleno.bg_color = color_barra_meta
		tween_barra = barra_ovillos.create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween_barra.tween_property(relleno, "bg_color", color_barra_meta.lightened(0.4), 0.5)
		tween_barra.tween_property(relleno, "bg_color", color_barra_meta, 0.5)
		tween_barra.set_loops()
	else:
		relleno.bg_color = color_barra_falta

func actualizar_salas() -> void:
	if not label_salas:
		return
	var total_salas : int = 0
	if GameManager.dificultad_actual:
		total_salas = GameManager.dificultad_actual.niveles_para_ganar
		if icono_dificultad:
			icono_dificultad.texture = GameManager.dificultad_actual.icono
			if not icono_dificultad.material:
				icono_dificultad.material = ShaderMaterial.new()
				icono_dificultad.material.shader = shader_contorno
				icono_dificultad.material.set_shader_parameter("grosor", grosor_contorno_dificultad)
			icono_dificultad.material.set_shader_parameter("color_borde", GameManager.dificultad_actual.color_seleccion)
	label_salas.text = "Salas: %d / %d" % [GameManager.niveles_ganados_run, total_salas]

func al_completar_nivel(exito: bool) -> void:
	actualizar_salas()
