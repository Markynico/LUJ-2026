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
##precio en monedas de curar una vida
@export var precio_curar_vida : int = 50
##escena de la tarjeta de item
@export var escena_tarjeta : PackedScene = preload("uid://u6k76f6lyw8y")
##tamaño base de la tarjeta, se escala solo para que entre la fila
@export var tamaño_tarjeta : Vector2 = Vector2(500, 600)
##separacion horizontal entre tarjetas de una fila
@export var separacion_tarjetas : float = 40.0

@export_group("Nodos")
@export var fila_reliquias : HBoxContainer
@export var fila_comidas : HBoxContainer
@export var boton_curar_vida : Button
@export var boton_continuar : Button
@export var foco : FocoTarjetas

var compra_en_foco : Dictionary = {}
var botones_compra : Array = []


func _ready() -> void:
	boton_continuar.pressed.connect(continuar_pedido.emit)
	boton_curar_vida.pressed.connect(curar_vida)
	foco.accion_pedida.connect(comprar_en_foco)
	foco.cerrado.connect(al_cerrar_foco)
	Global.monedas_cambiadas.connect(actualizar_monedas)
	boton_curar_vida.text = "Curar 1 vida  %d" % precio_curar_vida
	actualizar_monedas(Global.monedas)
	poblar_ofertas()


func poblar_ofertas() -> void:
	var reliquias : Array = []
	var comidas : Array = []
	await get_tree().process_frame
	for reliquia in Progreso.filtrar_desbloqueadas(pool_reliquias):
		if not ReliquiasManager.obtenidas.has(reliquia):
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
	return roundi(Rareza.precio_de(item) * (1.0 - ReliquiasManager.descuento_tienda()))


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
	var boton : Button
	envoltura.custom_minimum_size = tamaño_tarjeta * escala
	tarjeta.size = tamaño_tarjeta
	tarjeta.scale = Vector2.ONE * escala
	tarjeta.recurso = item
	envoltura.add_child(tarjeta)
	fila.add_child(envoltura)
	boton = tarjeta.mostrar_boton_precio(precio_de(item))
	boton.pressed.connect(comprar.bind(item, boton))
	botones_compra.append({"boton": boton, "item": item, "tarjeta": tarjeta})
	tarjeta.clickeada.connect(abrir_foco.bind(botones_compra.back()))
	actualizar_botones()






func abrir_foco(compra : Dictionary) -> void:
	if foco.esta_abierto():
		return
	compra_en_foco = compra
	compra["tarjeta"].estilizar_boton_precio(foco.boton_accion, precio_de(compra["item"]), true)
	foco.con_accion = compra["boton"].visible
	actualizar_botones()
	foco.abrir(compra["tarjeta"], compra["boton"].get_parent())


func al_cerrar_foco(tarjeta : Tarjeta) -> void:
	compra_en_foco = {}
	refrescar_hover()


func refrescar_hover() -> void:
	var mouse : Vector2 = get_global_mouse_position()
	for compra in botones_compra:
		if compra["tarjeta"].get_global_rect().has_point(mouse):
			compra["tarjeta"].mostrar_borde(true)


func comprar_en_foco(tarjeta : Tarjeta) -> void:
	if compra_en_foco.is_empty():
		return
	if not comprar(compra_en_foco["item"], compra_en_foco["boton"]):
		return
	foco.con_accion = false
	foco.boton_accion.hide()


func comprar(item : Resource, boton : Button) -> bool:
	if Global.monedas < precio_de(item):
		return false
	Global.actualizar_monedas(-precio_de(item))
	if item is Reliquia:
		ReliquiasManager.obtener(item)
	elif item is PelotitaBase:
		Global.agregar_pelotita_al_cargador(item)
		EstadisticasRun.registrar_comida_comprada()
	boton.disabled = true
	boton.hide()
	actualizar_botones()
	return true


func actualizar_monedas(monedas : int) -> void:
	actualizar_botones()


func actualizar_botones() -> void:
	var game_manager : GameManager = GameManager.instancia_actual
	if not compra_en_foco.is_empty() and foco.con_accion:
		compra_en_foco["tarjeta"].colorear_por_monedas(foco.boton_accion, precio_de(compra_en_foco["item"]))
	boton_curar_vida.disabled = Global.monedas < precio_curar_vida
	if game_manager:
		boton_curar_vida.disabled = boton_curar_vida.disabled or game_manager.vidas_actuales >= game_manager.vidas_maximas


func curar_vida() -> void:
	var game_manager : GameManager = GameManager.instancia_actual
	if Global.monedas < precio_curar_vida or not game_manager:
		return
	if game_manager.vidas_actuales >= game_manager.vidas_maximas:
		return
	Global.actualizar_monedas(-precio_curar_vida)
	game_manager.ganar_vida(1)
	EstadisticasRun.registrar_cura_comprada()
	actualizar_botones()
