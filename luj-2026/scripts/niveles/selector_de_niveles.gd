class_name SelectorDeNiveles
extends Node2D

signal nivel_elegido(tipo : TipoDeSala.Tipo)

##cargador que construye los niveles y tiene las divisiones
@export var cargador : CargadorDeNivel
##escena de area que representa cada salida
@export var escena_salida : PackedScene = preload("uid://csalida0000a1")
##minimo de divisores intermedios que puede tener el nivel
@export_range(0, 20, 1) var divisores_minimos : int = 0
##maximo de divisores intermedios que puede tener el nivel
@export_range(0, 20, 1) var divisores_maximos : int = 5
##tipos de sala que pueden aparecer como salida
@export var tipos_disponibles : Array[TipoDeSala.Tipo] = [
	TipoDeSala.Tipo.NORMAL,
	TipoDeSala.Tipo.TIENDA,
	TipoDeSala.Tipo.LOOT,
]
@export_group("Chances de sala")
##peso de las salas normales al sortear cada salida
@export_range(0.0, 1.0, 0.05) var chance_normal : float = 1.0
##peso de las salas de loot al sortear cada salida, se usa si no hay dificultad activa
@export_range(0.0, 1.0, 0.05) var chance_loot : float = 0.25
##probabilidad de que aparezca una tienda entre las salidas, se usa si no hay dificultad activa
@export_range(0.0, 1.0, 0.05) var chance_tienda : float = 0.25
##salas minimas entre tiendas, se usa si no hay dificultad activa
@export_range(0, 20, 1) var salas_entre_tiendas : int = 3
##salas minimas entre salas de loot, se usa si no hay dificultad activa
@export_range(0, 20, 1) var salas_entre_loots : int = 3
@export_group("")
##alto del area de cada salida
@export var alto_salida : float = 200.0

var salidas : Array[SalidaDeNivel] = []
var eleccion_hecha : bool = false
var salas_desde_tienda : int = 999
var salas_desde_loot : int = 999


func _ready() -> void:
	if cargador:
		cargador.nivel_construido.connect(preparar_salidas)
	if GameManager.instancia_actual:
		GameManager.instancia_actual.lanzar_gato.connect(mostrar_salidas)
	preparar_salidas.call_deferred()


func mostrar_salidas() -> void:
	for i in salidas.size():
		salidas[i].aparecer(i * 0.1)


func preparar_salidas() -> void:
	var divisiones : DivisionesPachinko = obtener_divisiones()
	eleccion_hecha = false
	if not divisiones:
		return
	divisiones.divisiones_intermedias = randi_range(divisores_minimos, divisores_maximos)
	colocar_salidas.call_deferred()


func colocar_salidas() -> void:
	var divisiones : DivisionesPachinko = obtener_divisiones()
	var ancho : float
	var salida : SalidaDeNivel
	var centros : Array[float]
	var tipos : Array[TipoDeSala.Tipo]
	for vieja in salidas:
		vieja.queue_free()
	salidas.clear()
	if not divisiones or not escena_salida or tipos_disponibles.is_empty():
		return
	ancho = divisiones.ancho_de_hueco()
	centros = divisiones.obtener_centros_de_huecos()
	tipos = elegir_tipos(centros.size())
	for i in centros.size():
		salida = escena_salida.instantiate()
		salida.tipo = tipos[i]
		salida.tamaño = Vector2(ancho, alto_salida)
		add_child(salida, true)
		salida.global_position = divisiones.to_global(Vector2(centros[i], 0))
		salida.elegida.connect(al_elegir_salida)
		salidas.append(salida)
	if ReliquiasManager.salidas_reveladas:
		mostrar_salidas()


func elegir_tipos(cantidad : int) -> Array[TipoDeSala.Tipo]:
	var tipos : Array[TipoDeSala.Tipo] = []
	var dificultad : DificultadRun = GameManager.dificultad_actual
	var peso_normal : float = chance_normal if tipos_disponibles.has(TipoDeSala.Tipo.NORMAL) else 0.0
	var chance_loot_activa : float = dificultad.chance_loot if dificultad else chance_loot
	var chance_tienda_activa : float = dificultad.chance_tienda if dificultad else chance_tienda
	var entre_tiendas : int = dificultad.salas_entre_tiendas if dificultad else salas_entre_tiendas
	var entre_loots : int = dificultad.salas_entre_loots if dificultad else salas_entre_loots
	var peso_loot : float = chance_loot_activa if tipos_disponibles.has(TipoDeSala.Tipo.LOOT) and salas_desde_loot >= entre_loots else 0.0
	var total : float = peso_normal + peso_loot
	var azar : float
	for i in cantidad:
		if total <= 0.0:
			tipos.append(TipoDeSala.Tipo.NORMAL)
			continue
		azar = randf() * total
		tipos.append(TipoDeSala.Tipo.NORMAL if azar < peso_normal else TipoDeSala.Tipo.LOOT)
	if tipos_disponibles.has(TipoDeSala.Tipo.TIENDA) and salas_desde_tienda >= entre_tiendas and cantidad > 0 and randf() < chance_tienda_activa:
		tipos[randi_range(0, cantidad - 1)] = TipoDeSala.Tipo.TIENDA
	return tipos


func obtener_divisiones() -> DivisionesPachinko:
	return cargador.obtener_divisiones() if cargador else null


func al_elegir_salida(salida : SalidaDeNivel) -> void:
	if eleccion_hecha:
		return
	eleccion_hecha = true
	salas_desde_tienda += 1
	salas_desde_loot += 1
	if salida.tipo == TipoDeSala.Tipo.TIENDA:
		salas_desde_tienda = 0
	elif salida.tipo == TipoDeSala.Tipo.LOOT:
		salas_desde_loot = 0
	nivel_elegido.emit(salida.tipo)
