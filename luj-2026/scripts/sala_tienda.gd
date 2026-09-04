class_name SalaTienda
extends Control

signal continuar_pedido

##reliquias en oferta en la fila de arriba
@export var cantidad_reliquias : int = 3
##comidas en oferta en la fila de abajo
@export var cantidad_comidas : int = 3
##precio en monedas de curar una vida
@export var precio_curar_vida : int = 50
##aumento del precio de curar por cada vida ya comprada en esta tienda, 0.25 = 25%
@export var aumento_por_cura : float = 0.25
##precio en monedas del primer refresco de items
@export var precio_refrescar : int = 100
##monedas que se suman al precio por cada refresco ya hecho en esta tienda
@export var aumento_por_refresco : int = 50
##segundos entre la entrada de una tarjeta y la siguiente
@export var retardo_entre_tarjetas : float = 0.08
##escena de la tarjeta de item
@export var escena_tarjeta : PackedScene = preload("uid://u6k76f6lyw8y")
##tamaño base de la tarjeta, se escala solo para que entre la fila
@export var tamaño_tarjeta : Vector2 = Vector2(500, 600)
##separacion horizontal entre tarjetas de una fila
@export var separacion_tarjetas : float = 40.0

@export_group("Oferta fija (pruebas)")
##reliquias que se muestran en vez de sortear, vacio = sorteo normal
@export var reliquias_fijas : Array[Reliquia] = []
##comidas que se muestran en vez de sortear, vacio = sorteo normal
@export var comidas_fijas : Array[PelotitaBase] = []
@export_group("")

@export_group("Nodos")
@export var fila_reliquias : HBoxContainer
@export var fila_comidas : HBoxContainer
@export var boton_curar_vida : Button
@export var texto_curar : RichTextLabel
@export var boton_refrescar : Button
@export var texto_refrescar : RichTextLabel
@export var boton_continuar : Button
@export var foco : FocoTarjetas

var compra_en_foco : Dictionary = {}
var botones_compra : Array = []
var curas_compradas_aca : int = 0
var refrescos_hechos_aca : int = 0


func _ready() -> void:
	boton_continuar.pressed.connect(continuar_pedido.emit)
	boton_curar_vida.pressed.connect(curar_vida)
	boton_refrescar.pressed.connect(refrescar_ofertas)
	foco.accion_pedida.connect(comprar_en_foco)
	foco.cerrado.connect(al_cerrar_foco)
	Global.monedas_cambiadas.connect(actualizar_monedas)
	actualizar_texto_curar()
	actualizar_texto_refrescar()
	actualizar_monedas(Global.monedas)
	poblar_ofertas()


func poblar_ofertas() -> void:
	await get_tree().process_frame
	armar_fila(fila_reliquias, oferta_inicial(reliquias_fijas, candidatos_reliquias(), cantidad_reliquias), 0.0)
	armar_fila(fila_comidas, oferta_inicial(comidas_fijas, candidatos_comidas(), cantidad_comidas), cantidad_reliquias * retardo_entre_tarjetas)


func oferta_inicial(fijos : Array, candidatos : Array, cantidad : int) -> Array:
	if fijos.is_empty():
		return elegir_oferta(candidatos, cantidad)
	return fijos.filter(func(item : Resource) -> bool: return item != null)


func candidatos_reliquias() -> Array:
	var reliquias : Array = []
	for reliquia in Progreso.filtrar_desbloqueadas(CatalogoItems.reliquias_en_tienda()):
		if not ReliquiasManager.obtenidas.has(reliquia):
			reliquias.append(reliquia)
	return reliquias


func candidatos_comidas() -> Array:
	return Progreso.filtrar_desbloqueadas(CatalogoItems.comidas_en_tienda())


func elegir_oferta(candidatos : Array, cantidad : int, repetir : bool = false) -> Array:
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
		if not repetir:
			restantes.erase(elegido)
	return oferta


func precio_de(item : Resource) -> int:
	return roundi(Rareza.precio_de(item) * (1.0 - ReliquiasManager.descuento_tienda()))


func armar_fila(fila : HBoxContainer, items : Array, retardo_inicial : float) -> void:
	var escala : float = calcular_escala(fila, items.size())
	fila.add_theme_constant_override("separation", int(separacion_tarjetas))
	for indice in items.size():
		crear_puesto(fila, items[indice], escala, -1, retardo_inicial + indice * retardo_entre_tarjetas)


func calcular_escala(fila : HBoxContainer, cantidad : int) -> float:
	var ancho_disponible : float
	if cantidad <= 0:
		return 1.0
	ancho_disponible = (fila.size.x - separacion_tarjetas * (cantidad - 1)) / cantidad
	return minf(1.0, minf(ancho_disponible / tamaño_tarjeta.x, fila.size.y / tamaño_tarjeta.y))


func crear_puesto(fila : HBoxContainer, item : Resource, escala : float, indice : int = -1, retardo : float = 0.0) -> void:
	var envoltura : Control = Control.new()
	var tarjeta : Tarjeta = escena_tarjeta.instantiate()
	var boton : Button
	envoltura.custom_minimum_size = tamaño_tarjeta * escala
	tarjeta.size = tamaño_tarjeta
	tarjeta.scale = Vector2.ONE * escala
	tarjeta.recurso = item
	envoltura.add_child(tarjeta)
	fila.add_child(envoltura)
	if indice >= 0:
		fila.move_child(envoltura, indice)
	boton = tarjeta.mostrar_boton_precio(precio_de(item))
	boton.pressed.connect(comprar.bind(item, boton))
	botones_compra.append({"boton": boton, "item": item, "tarjeta": tarjeta, "fila": fila, "comprado": false})
	tarjeta.clickeada.connect(abrir_foco.bind(botones_compra.back()))
	tarjeta.animar_entrada(retardo)
	actualizar_botones()


func puestos_de(fila : HBoxContainer, solo_sin_comprar : bool) -> Array:
	return botones_compra.filter(func(compra : Dictionary) -> bool:
		return compra["fila"] == fila and (not solo_sin_comprar or not compra["comprado"]))


func puestos_refrescables() -> Array:
	return botones_compra.filter(func(compra : Dictionary) -> bool: return not compra["comprado"])


func refrescar_ofertas() -> void:
	if foco.esta_abierto() or puestos_refrescables().is_empty():
		return
	if Global.monedas < precio_refrescar_actual():
		return
	Global.actualizar_monedas(-precio_refrescar_actual())
	AudioManager.reproducir_sfx(EfectoDeSonido.Tipo.COMPRAR)
	refrescos_hechos_aca += 1
	reponer_fila(fila_reliquias, candidatos_reliquias(), false, 0.0)
	reponer_fila(fila_comidas, candidatos_comidas(), true, puestos_de(fila_reliquias, true).size() * retardo_entre_tarjetas)
	actualizar_texto_refrescar()
	actualizar_botones()


func reponer_fila(fila : HBoxContainer, candidatos : Array, repetir : bool, retardo_inicial : float) -> void:
	var a_reponer : Array = puestos_de(fila, true)
	var nuevos : Array = elegir_oferta(candidatos, a_reponer.size(), repetir)
	var escala : float = calcular_escala(fila, puestos_de(fila, false).size())
	var envoltura : Control
	for orden in mini(a_reponer.size(), nuevos.size()):
		envoltura = a_reponer[orden]["tarjeta"].get_parent()
		botones_compra.erase(a_reponer[orden])
		crear_puesto(fila, nuevos[orden], escala, envoltura.get_index(), retardo_inicial + orden * retardo_entre_tarjetas)
		envoltura.queue_free()


func precio_refrescar_actual() -> int:
	return precio_refrescar + aumento_por_refresco * refrescos_hechos_aca


func actualizar_texto_refrescar() -> void:
	texto_refrescar.text = "[center]" + Resaltador.formatear("Refrescar por {monedas:icono} %d" % precio_refrescar_actual())




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
			compra["tarjeta"].al_hover(true)


func comprar_en_foco(tarjeta : Tarjeta) -> void:
	if compra_en_foco.is_empty():
		return
	if not comprar(compra_en_foco["item"], compra_en_foco["boton"]):
		return
	foco.con_accion = false
	foco.boton_accion.hide()


func comprar(item : Resource, boton : Button) -> bool:
	var compra : Dictionary = puesto_de_boton(boton)
	if Global.monedas < precio_de(item):
		return false
	Global.actualizar_monedas(-precio_de(item))
	AudioManager.reproducir_sfx(EfectoDeSonido.Tipo.COMPRAR)
	if item is Reliquia:
		ReliquiasManager.obtener(item)
	elif item is PelotitaBase:
		Global.agregar_pelotita_al_cargador(item)
		EstadisticasRun.registrar_comida_comprada()
	boton.disabled = true
	boton.hide()
	if not compra.is_empty():
		compra["comprado"] = true
		compra["tarjeta"].marcar_comprado()
	actualizar_botones()
	return true


func puesto_de_boton(boton : Button) -> Dictionary:
	for compra in botones_compra:
		if compra["boton"] == boton:
			return compra
	return {}


func actualizar_monedas(monedas : int) -> void:
	actualizar_botones()


func actualizar_botones() -> void:
	var game_manager : GameManager = GameManager.instancia_actual
	if not compra_en_foco.is_empty() and foco.con_accion:
		compra_en_foco["tarjeta"].colorear_por_monedas(foco.boton_accion, precio_de(compra_en_foco["item"]))
	boton_curar_vida.disabled = Global.monedas < precio_curar_actual()
	boton_refrescar.disabled = Global.monedas < precio_refrescar_actual() or foco.esta_abierto() or puestos_refrescables().is_empty()
	if game_manager:
		boton_curar_vida.disabled = boton_curar_vida.disabled or game_manager.vidas_actuales >= game_manager.vidas_maximas


func precio_curar_actual() -> int:
	return roundi(precio_curar_vida * pow(1.0 + aumento_por_cura, curas_compradas_aca))


func actualizar_texto_curar() -> void:
	texto_curar.text = "[center]" + Resaltador.formatear("Curar 1 {vida:icono} por {monedas:icono} %d" % precio_curar_actual())


func curar_vida() -> void:
	var game_manager : GameManager = GameManager.instancia_actual
	if Global.monedas < precio_curar_actual() or not game_manager:
		return
	if game_manager.vidas_actuales >= game_manager.vidas_maximas:
		return
	Global.actualizar_monedas(-precio_curar_actual())
	AudioManager.reproducir_sfx(EfectoDeSonido.Tipo.COMPRAR)
	curas_compradas_aca += 1
	game_manager.ganar_vida(1)
	EstadisticasRun.registrar_cura_comprada()
	actualizar_texto_curar()
	actualizar_botones()
