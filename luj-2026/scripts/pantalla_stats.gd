class_name PantallaStats
extends Control

##escena del menu a la que vuelve el boton
@export_file("*.tscn") var escena_menu : String = "uid://c30ry4xehty4"
##titulo cuando se gana la run
@export var titulo_victoria : String = "¡Ganaste!"
##titulo cuando se pierde la run
@export var titulo_derrota : String = "Fin de la run"
##alto en pixeles de los iconos de reliquias
@export var alto_icono_reliquia : float = 64.0
##tamaño de fuente de las filas de stats
@export var tamaño_fuente_stats : int = 38

@export_group("Nodos")
@export var label_titulo : Label
@export var contenedor_stats : GridContainer
@export var contenedor_reliquias : HBoxContainer
@export var boton_volver : Button


func _ready() -> void:
	label_titulo.text = titulo_victoria if EstadisticasRun.gano_la_run else titulo_derrota
	boton_volver.pressed.connect(volver_al_menu)
	agregar_stat("Tiempo", formatear_tiempo(EstadisticasRun.duracion_segundos()))
	agregar_stat("Puntos totales", str(EstadisticasRun.puntos_totales))
	agregar_stat("Mejor nivel", str(EstadisticasRun.mejor_puntaje_nivel))
	agregar_stat("Niveles", "%d ganados / %d perdidos" % [EstadisticasRun.niveles_ganados, EstadisticasRun.niveles_perdidos])
	agregar_stat("Monedas conseguidas", str(EstadisticasRun.monedas_conseguidas))
	agregar_stat("Monedas gastadas", str(EstadisticasRun.monedas_gastadas))
	agregar_stat("Comidas compradas", str(EstadisticasRun.comidas_compradas))
	agregar_stat("Ovillos rotos", str(EstadisticasRun.ovillos_rotos))
	agregar_stat("Bolas disparadas", str(EstadisticasRun.bolas_disparadas))
	mostrar_reliquias()


func agregar_stat(nombre : String, valor : String) -> void:
	var label_nombre : Label = Label.new()
	var label_valor : Label = Label.new()
	label_nombre.text = nombre
	label_valor.text = valor
	label_nombre.add_theme_font_size_override("font_size", tamaño_fuente_stats)
	label_valor.add_theme_font_size_override("font_size", tamaño_fuente_stats)
	label_valor.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	label_valor.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	contenedor_stats.add_child(label_nombre)
	contenedor_stats.add_child(label_valor)


func mostrar_reliquias() -> void:
	var icono : TextureRect
	for reliquia in EstadisticasRun.reliquias_adquiridas:
		if not reliquia.icono:
			continue
		icono = TextureRect.new()
		icono.texture = reliquia.icono
		icono.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icono.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icono.custom_minimum_size = Vector2(reliquia.icono.get_width() * alto_icono_reliquia / reliquia.icono.get_height(), alto_icono_reliquia)
		icono.tooltip_text = reliquia.nombre
		contenedor_reliquias.add_child(icono)


func formatear_tiempo(segundos : float) -> String:
	return "%02d:%02d" % [int(segundos) / 60, int(segundos) % 60]


func volver_al_menu() -> void:
	Transicion.cambiar_escena(escena_menu)
