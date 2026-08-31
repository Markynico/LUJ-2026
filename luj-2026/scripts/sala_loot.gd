class_name SalaLoot
extends Control

signal continuar_pedido

##reliquias que pueden aparecer, se elige al azar entre las que no se tienen
@export var reliquias_posibles : Array[Reliquia] = []
##escena de la tarjeta de reliquia
@export var escena_tarjeta : PackedScene = preload("uid://u6k76f6lyw8y")
##tamaño base de la tarjeta
@export var tamaño_tarjeta : Vector2 = Vector2(500, 600)
##escala de las tarjetas cuando hay mas de una opcion
@export var escala_multiple : float = 0.8
@export var contenedor_tarjetas : HBoxContainer
@export var foco : FocoTarjetas
@export var boton_aceptar : Button
@export var boton_rechazar : Button

var reliquia : Reliquia


func _ready() -> void:
	var candidatos : Array = Progreso.filtrar_desbloqueadas(reliquias_posibles).filter(
		func(posible : Reliquia) -> bool: return not ReliquiasManager.obtenidas.has(posible)
	)
	var opciones : int = ReliquiasManager.opciones_loot
	var elegida : Reliquia
	boton_aceptar.pressed.connect(aceptar_unica)
	boton_rechazar.pressed.connect(rechazar)
	foco.accion_pedida.connect(al_accion_foco)
	if candidatos.is_empty():
		continuar_pedido.emit.call_deferred()
		return
	if candidatos.size() > 1:
		candidatos.erase(ReliquiasManager.ultima_ofrecida)
	for indice in mini(opciones, candidatos.size()):
		if GameManager.instancia_actual:
			elegida = GameManager.filtrar_por_rareza(candidatos, GameManager.instancia_actual.sortear_rareza()).pick_random()
		else:
			elegida = candidatos.pick_random()
		candidatos.erase(elegida)
		crear_tarjeta(elegida)
	reliquia = obtener_tarjetas()[0].recurso
	ReliquiasManager.ultima_ofrecida = reliquia
	boton_aceptar.visible = obtener_tarjetas().size() == 1


func crear_tarjeta(elegida : Reliquia) -> void:
	var envoltura : Control = Control.new()
	var tarjeta : Tarjeta = escena_tarjeta.instantiate()
	var escala : float = 1.0 if ReliquiasManager.opciones_loot <= 1 else escala_multiple
	envoltura.custom_minimum_size = tamaño_tarjeta * escala
	tarjeta.size = tamaño_tarjeta
	tarjeta.scale = Vector2.ONE * escala
	tarjeta.recurso = elegida
	tarjeta.clickeada.connect(al_click_tarjeta.bind(tarjeta))
	envoltura.add_child(tarjeta)
	contenedor_tarjetas.add_child(envoltura)


func obtener_tarjetas() -> Array[Tarjeta]:
	var tarjetas : Array[Tarjeta] = []
	for envoltura in contenedor_tarjetas.get_children():
		tarjetas.append(envoltura.get_child(0))
	return tarjetas


func al_click_tarjeta(tarjeta : Tarjeta) -> void:
	foco.boton_accion.text = "Aceptar"
	foco.abrir(tarjeta, boton_aceptar if boton_aceptar.visible else null)


func al_accion_foco(tarjeta : Tarjeta) -> void:
	aceptar(tarjeta.recurso)


func aceptar_unica() -> void:
	aceptar(reliquia)


func aceptar(elegida : Reliquia) -> void:
	ReliquiasManager.obtener(elegida)
	EstadisticasRun.registrar_reliquia_loot()
	continuar_pedido.emit()


func rechazar() -> void:
	continuar_pedido.emit()
