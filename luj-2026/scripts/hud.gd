class_name HUD
extends Control

@export var game_manager : GameManager
##shader que dibuja el contorno del icono de dificultad siguiendo el sprite
@export var shader_contorno : Shader = preload("res://scripts/shaders/contorno_seleccion.gdshader")
##grosor del contorno del icono de dificultad
@export var grosor_contorno_dificultad : float = 5.0
##color de la barra de progreso mientras no se llego al objetivo
@export var color_barra_falta : Color = Color(0.8, 0.18, 0.15)
##color de la barra de progreso al cumplir el objetivo, pulsa hacia mas claro
@export var color_barra_meta : Color = Color(0.2, 0.75, 0.48)

@onready var barra_ovillos : ProgressBar = %BarraOvillos
@onready var label_ovillos : Label = %LabelOvillos
@onready var label_salas : Label = %LabelSalas
@onready var icono_dificultad : TextureRect = %IconoDificultad
@onready var bolas_restantes_label : Label = %BolasRestantes if has_node("%BolasRestantes") else null
@onready var monedas_label : Label = %Monedas if has_node("%Monedas") else null

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
		game_manager.puntos_actualizados.connect(actualizar_progreso_ovillos)
		game_manager.nivel_completado.connect(al_completar_nivel)

		# Inicializar vistas
		actualizar_bolas_restantes(game_manager.bolas_restantes)
		actualizar_salas()

func actualizar_bolas_restantes(cantidad: int) -> void:
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
