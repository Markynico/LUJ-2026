class_name SalaTienda
extends Control

signal continuar_pedido

##reliquias que pueden aparecer a la venta, se excluyen las ya obtenidas
@export var pool_reliquias : Array[Reliquia] = []
##comidas que pueden aparecer a la venta
@export var pool_comidas : Array[PelotitaBase] = []
##reliquias en oferta en la fila de arriba
@export var cantidad_reliquias : int = 3
##comidas en oferta en la fila de abajo
@export var cantidad_comidas : int = 3
##precio en monedas de remover una comida
@export var precio_remover_comida : int = 30
##precio en monedas de curar una vida
@export var precio_curar_vida : int = 50
##escena de la tarjeta de item
@export var escena_tarjeta : PackedScene = preload("uid://u6k76f6lyw8y")
##tamaño base de la tarjeta, se escala solo para que entre la fila
@export var tamaño_tarjeta : Vector2 = Vector2(500, 600)
##separacion horizontal entre tarjetas de una fila
@export var separacion_tarjetas : float = 40.0
##tamaño de fuente del boton de comprar
@export var fuente_boton_comprar : int = 22
##relleno interno del boton de comprar (horizontal, vertical)
@export var relleno_boton_comprar : Vector2 = Vector2(30, 16)
##color del boton de compra cuando alcanza la plata
@export var color_compra_alcanza : Color = Color("3f8f3f")
##color del boton de compra cuando no alcanza la plata
@export var color_compra_no_alcanza : Color = Color("9c3030")
##escala de la tarjeta cuando esta en foco
@export var escala_foco : float = 1.0
##segundos de la animacion de foco
@export var duracion_foco : float = 0.4
##separacion fija de los botones de foco con los bordes de la tarjeta
@export var separacion_botones_foco : float = 40.0
##escala del boton de comprar cuando esta en foco
@export var escala_boton_foco : float = 1.6
##fuente de los botones de compra
@export var fuente_botones : FontFile = preload("uid://dwg47e0trev3j")
##icono de moneda que acompaña los precios
@export var icono_moneda : Texture2D = preload("uid://cmgxgm42kfbke")
##alto del icono de moneda en los botones
@export var tamaño_icono_moneda : int = 44

@export_group("Nodos")
@export var fila_reliquias : HBoxContainer
@export var fila_comidas : HBoxContainer
@export var boton_remover_comida : Button
@export var boton_curar_vida : Button
@export var boton_continuar : Button
@export var panel_remover : Control
@export var contenedor_remover : VBoxContainer
@export var boton_cancelar_remover : Button
@export var vista_foco : Control
@export var oscurecedor : ColorRect
@export var boton_volver_foco : Button
@export var boton_comprar_foco : Button

var tarjeta_en_foco : Tarjeta
var compra_en_foco : Dictionary = {}
var posicion_original_foco : Vector2
var posicion_boton_original : Vector2
var escala_original_foco : Vector2
var tween_foco : Tween

var botones_compra : Array = []


func _ready() -> void:
	boton_continuar.pressed.connect(continuar_pedido.emit)
	boton_remover_comida.pressed.connect(abrir_remover_comida)
	boton_curar_vida.pressed.connect(curar_vida)
	boton_cancelar_remover.pressed.connect(panel_remover.hide)
	boton_volver_foco.pressed.connect(cerrar_foco)
	boton_comprar_foco.pressed.connect(comprar_en_foco)
	oscurecedor.gui_input.connect(al_click_oscurecedor)
	vista_foco.hide()
	Global.monedas_cambiadas.connect(actualizar_monedas)
	panel_remover.hide()
	boton_remover_comida.text = "Remover comida  %d" % precio_remover_comida
	boton_curar_vida.text = "Curar 1 vida  %d" % precio_curar_vida
	actualizar_monedas(Global.monedas)
	poblar_ofertas()


func poblar_ofertas() -> void:
	var reliquias : Array = []
	var comidas : Array = []
	await get_tree().process_frame
	for reliquia in pool_reliquias:
		if reliquia and not ReliquiasManager.obtenidas.has(reliquia):
			reliquias.append(reliquia)
	for comida in pool_comidas:
		if comida:
			comidas.append(comida)
	armar_fila(fila_reliquias, elegir_oferta(reliquias, cantidad_reliquias))
	armar_fila(fila_comidas, elegir_oferta(comidas, cantidad_comidas))


func elegir_oferta(candidatos : Array, cantidad : int) -> Array:
	var oferta : Array = []
	var restantes : Array = candidatos.duplicate()
	var game_manager : GameManager = GameManager.instancia_actual
	var rareza : Rareza.Nivel = Rareza.Nivel.COMUN
	var opciones : Array = []
	var elegido : Resource
	for indice in cantidad:
		if restantes.is_empty():
			break
		if game_manager:
			rareza = game_manager.sortear_rareza()
		opciones = GameManager.filtrar_por_rareza(restantes, rareza)
		elegido = opciones.pick_random()
		oferta.append(elegido)
		restantes.erase(elegido)
	return oferta


func precio_de(item : Resource) -> int:
	return Rareza.precio_de(item)


func armar_fila(fila : HBoxContainer, items : Array) -> void:
	var escala : float = calcular_escala(fila, items.size())
	fila.add_theme_constant_override("separation", int(separacion_tarjetas))
	for item in items:
		crear_puesto(fila, item, escala)


func calcular_escala(fila : HBoxContainer, cantidad : int) -> float:
	var ancho_disponible : float
	if cantidad <= 0:
		return 1.0
	ancho_disponible = (fila.size.x - separacion_tarjetas * (cantidad - 1)) / cantidad
	return minf(1.0, minf(ancho_disponible / tamaño_tarjeta.x, fila.size.y / tamaño_tarjeta.y))


func crear_puesto(fila : HBoxContainer, item : Resource, escala : float) -> void:
	var envoltura : Control = Control.new()
	var tarjeta : Tarjeta = escena_tarjeta.instantiate()
	var margen : MarginContainer = MarginContainer.new()
	var boton : Button = Button.new()
	envoltura.custom_minimum_size = tamaño_tarjeta * escala
	tarjeta.size = tamaño_tarjeta
	tarjeta.scale = Vector2.ONE * escala
	tarjeta.recurso = item
	margen.set_anchors_preset(Control.PRESET_FULL_RECT)
	margen.add_theme_constant_override("margin_bottom", 24)
	margen.add_theme_constant_override("margin_right", 24)
	boton.size_flags_horizontal = Control.SIZE_SHRINK_END
	boton.size_flags_vertical = Control.SIZE_SHRINK_END
	boton.add_theme_font_size_override("font_size", fuente_boton_comprar)
	boton.pressed.connect(comprar.bind(item, boton))
	botones_compra.append({"boton": boton, "item": item, "tarjeta": tarjeta})
	tarjeta.clickeada.connect(abrir_foco.bind(botones_compra.back()))
	margen.add_child(boton)
	tarjeta.add_child(margen)
	envoltura.add_child(tarjeta)
	fila.add_child(envoltura)
	preparar_boton_con_precio(boton, str(precio_de(item)))
	actualizar_botones()




func preparar_boton_con_precio(boton : Button, texto : String) -> void:
	boton.text = texto
	boton.icon = icono_moneda
	boton.add_theme_font_override("font", fuente_botones)
	for nombre in ["font_color", "font_hover_color", "font_pressed_color", "font_hover_pressed_color", "font_focus_color"]:
		boton.add_theme_color_override(nombre, Color.WHITE)
	boton.alignment = HORIZONTAL_ALIGNMENT_LEFT
	boton.add_theme_constant_override("icon_max_width", tamaño_icono_moneda)
	for estado in ["normal", "hover", "pressed"]:
		achicar_estilo(boton, estado)


func colorear_boton(boton : Button, color : Color) -> void:
	for estado in ["normal", "hover", "pressed"]:
		var estilo : StyleBoxFlat = boton.get_theme_stylebox(estado)
		if estilo and estilo.has_meta("bg_original"):
			estilo.bg_color = estilo.get_meta("bg_original").lerp(color, 0.6)
			estilo.border_color = estilo.get_meta("borde_original").lerp(color, 0.6).darkened(0.3)


func achicar_estilo(boton : Button, estado : String) -> void:
	var estilo : StyleBoxFlat = boton.get_theme_stylebox(estado).duplicate()
	estilo.expand_margin_left = 0.0
	estilo.expand_margin_top = 0.0
	estilo.expand_margin_right = 0.0
	estilo.expand_margin_bottom = 0.0
	estilo.content_margin_left = relleno_boton_comprar.x
	estilo.content_margin_top = relleno_boton_comprar.y
	estilo.content_margin_right = relleno_boton_comprar.x
	estilo.content_margin_bottom = relleno_boton_comprar.y
	estilo.set_meta("bg_original", estilo.bg_color)
	estilo.set_meta("borde_original", estilo.border_color)
	boton.add_theme_stylebox_override(estado, estilo)


func al_click_oscurecedor(evento : InputEvent) -> void:
	if evento is InputEventMouseButton and evento.button_index == MOUSE_BUTTON_LEFT and evento.pressed:
		cerrar_foco()


func abrir_foco(compra : Dictionary) -> void:
	var tarjeta : Tarjeta = compra["tarjeta"]
	var centro : Vector2 = get_viewport_rect().size * 0.5
	var destino : Vector2 = centro - tamaño_tarjeta * escala_foco * 0.5
	if tarjeta_en_foco:
		return
	tarjeta_en_foco = tarjeta
	compra_en_foco = compra
	posicion_original_foco = tarjeta.global_position
	escala_original_foco = tarjeta.scale
	tarjeta.top_level = true
	tarjeta.global_position = posicion_original_foco
	tarjeta.z_index = 20
	preparar_boton_con_precio(boton_comprar_foco, str(precio_de(compra["item"])))
	boton_comprar_foco.add_theme_font_size_override("font_size", fuente_boton_comprar)
	boton_comprar_foco.disabled = compra["boton"].disabled
	boton_comprar_foco.visible = not compra["boton"].disabled
	actualizar_botones()
	compra["tarjeta"].hover_activado = false
	compra["tarjeta"].mostrar_borde(false)
	posicion_boton_original = compra["boton"].global_position
	compra["boton"].get_parent().hide()
	vista_foco.modulate.a = 0.0
	vista_foco.show()
	boton_comprar_foco.reset_size()
	boton_volver_foco.reset_size()
	boton_volver_foco.global_position = Vector2(destino.x - separacion_botones_foco - boton_volver_foco.size.x, centro.y - boton_volver_foco.size.y * 0.5)
	boton_comprar_foco.global_position = posicion_boton_original
	boton_comprar_foco.scale = escala_original_foco
	animar_foco(destino, Vector2.ONE * escala_foco, 1.0)
	if boton_comprar_foco.visible:
		tween_foco.tween_property(boton_comprar_foco, "global_position", Vector2(destino.x + tamaño_tarjeta.x * escala_foco + separacion_botones_foco, centro.y - boton_comprar_foco.size.y * escala_boton_foco * 0.5), duracion_foco)
		tween_foco.tween_property(boton_comprar_foco, "scale", Vector2.ONE * escala_boton_foco, duracion_foco)


func cerrar_foco() -> void:
	if not tarjeta_en_foco:
		return
	animar_foco(posicion_original_foco, escala_original_foco, 0.0)
	tween_foco.tween_callback(entrar_boton_chico.bind(compra_en_foco["boton"].get_parent())).set_delay(duracion_foco * 0.55)
	tween_foco.chain().tween_callback(terminar_cierre_foco)


func terminar_cierre_foco() -> void:
	if not tarjeta_en_foco:
		return
	tarjeta_en_foco.top_level = false
	tarjeta_en_foco.z_index = 0
	tarjeta_en_foco.position = Vector2.ZERO
	boton_comprar_foco.scale = Vector2.ONE
	vista_foco.hide()
	compra_en_foco["tarjeta"].hover_activado = true
	tarjeta_en_foco = null
	compra_en_foco = {}
	refrescar_hover()


func refrescar_hover() -> void:
	var mouse : Vector2 = get_global_mouse_position()
	for compra in botones_compra:
		if compra["tarjeta"].get_global_rect().has_point(mouse):
			compra["tarjeta"].mostrar_borde(true)


func entrar_boton_chico(margen : Control) -> void:
	var tween : Tween = margen.create_tween().set_parallel().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	margen.show()
	margen.modulate.a = 0.0
	margen.position = Vector2(40.0, 0.0)
	tween.tween_property(margen, "modulate:a", 1.0, 0.25)
	tween.tween_property(margen, "position", Vector2.ZERO, 0.25)


func animar_foco(destino : Vector2, escala : Vector2, alpha_vista : float) -> void:
	if tween_foco:
		tween_foco.kill()
	tween_foco = create_tween().set_parallel().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween_foco.tween_property(tarjeta_en_foco, "global_position", destino, duracion_foco)
	tween_foco.tween_property(tarjeta_en_foco, "scale", escala, duracion_foco)
	tween_foco.tween_property(vista_foco, "modulate:a", alpha_vista, duracion_foco)


func comprar_en_foco() -> void:
	if compra_en_foco.is_empty():
		return
	if not comprar(compra_en_foco["item"], compra_en_foco["boton"]):
		return
	boton_comprar_foco.disabled = true
	boton_comprar_foco.hide()


func comprar(item : Resource, boton : Button) -> bool:
	if Global.monedas < precio_de(item):
		return false
	Global.actualizar_monedas(-precio_de(item))
	if item is Reliquia:
		ReliquiasManager.obtener(item)
	elif item is PelotitaBase:
		Global.agregar_pelotita_al_cargador(item)
	boton.disabled = true
	boton.hide()
	return true


func actualizar_monedas(monedas : int) -> void:
	actualizar_botones()


func actualizar_botones() -> void:
	var game_manager : GameManager = GameManager.instancia_actual
	for compra in botones_compra:
		if compra["boton"].disabled:
			continue
		if Global.monedas >= precio_de(compra["item"]):
			colorear_boton(compra["boton"], color_compra_alcanza)
		else:
			colorear_boton(compra["boton"], color_compra_no_alcanza)
	if not compra_en_foco.is_empty() and not boton_comprar_foco.disabled:
		if Global.monedas >= precio_de(compra_en_foco["item"]):
			colorear_boton(boton_comprar_foco, color_compra_alcanza)
		else:
			colorear_boton(boton_comprar_foco, color_compra_no_alcanza)
	boton_remover_comida.disabled = Global.monedas < precio_remover_comida or Global.comidas_elegidas.is_empty()
	boton_curar_vida.disabled = Global.monedas < precio_curar_vida
	if game_manager:
		boton_curar_vida.disabled = boton_curar_vida.disabled or game_manager.vidas_actuales >= game_manager.vidas_maximas


func abrir_remover_comida() -> void:
	var boton : Button
	for hijo in contenedor_remover.get_children():
		if hijo is Button:
			hijo.queue_free()
	for indice in Global.comidas_elegidas.size():
		boton = Button.new()
		boton.text = Global.comidas_elegidas[indice].nombre
		boton.pressed.connect(remover_comida.bind(indice))
		contenedor_remover.add_child(boton)
	panel_remover.show()


func remover_comida(indice : int) -> void:
	if Global.monedas < precio_remover_comida or indice >= Global.comidas_elegidas.size():
		panel_remover.hide()
		return
	Global.actualizar_monedas(-precio_remover_comida)
	Global.comidas_elegidas.remove_at(indice)
	panel_remover.hide()


func curar_vida() -> void:
	var game_manager : GameManager = GameManager.instancia_actual
	if Global.monedas < precio_curar_vida or not game_manager:
		return
	if game_manager.vidas_actuales >= game_manager.vidas_maximas:
		return
	Global.actualizar_monedas(-precio_curar_vida)
	game_manager.ganar_vida(1)
	actualizar_botones()
