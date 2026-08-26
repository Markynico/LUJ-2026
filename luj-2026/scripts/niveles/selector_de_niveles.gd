class_name SelectorDeNiveles
extends Node2D

signal nivel_elegido(tipo : TipoDeSala.Tipo)

##cargador que construye los niveles y tiene las divisiones
@export var cargador : CargadorDeNivel
##escena de area que representa cada salida
@export var escena_salida : PackedScene = preload("uid://csalida0000a1")
##minimo de divisores intermedios que puede tener el nivel
@export_range(0, 20, 1) var divisores_minimos : int = 2
##maximo de divisores intermedios que puede tener el nivel
@export_range(0, 20, 1) var divisores_maximos : int = 5
##tipos de sala que pueden aparecer como salida
@export var tipos_disponibles : Array[TipoDeSala.Tipo] = [
	TipoDeSala.Tipo.NORMAL,
	TipoDeSala.Tipo.TIENDA,
	TipoDeSala.Tipo.LOOT,
]
##niveles que se pueden elegir como destino
@export var niveles_disponibles : Array[NivelData] = []
##alto del area de cada salida
@export var alto_salida : float = 200.0
##probabilidad de que aparezca una tienda entre las salidas, nunca mas de una
@export_range(0.0, 1.0, 0.05) var chance_tienda : float = 0.25

var salidas : Array[SalidaDeNivel] = []
var eleccion_hecha : bool = false


func _ready() -> void:
	if cargador:
		cargador.nivel_construido.connect(preparar_salidas)
	preparar_salidas.call_deferred()


func preparar_salidas() -> void:
	var divisiones : DivisionesPachinko = obtener_divisiones()
	eleccion_hecha = false
	if not divisiones:
		return
	divisiones.divisiones_intermedias = randi_range(divisores_minimos, divisores_maximos)
	colocar_salidas.call_deferred()


func colocar_salidas() -> void:
	for salida in salidas:
		salida.queue_free()
	salidas.clear()
	var divisiones : DivisionesPachinko = obtener_divisiones()
	var ancho : float
	var salida : SalidaDeNivel
	if not divisiones or not escena_salida or tipos_disponibles.is_empty():
		return
	ancho = divisiones.ancho_de_hueco()
	var centros : Array[float] = divisiones.obtener_centros_de_huecos()
	var tipos : Array[TipoDeSala.Tipo] = elegir_tipos(centros.size())
	for i in centros.size():
		salida = escena_salida.instantiate()
		salida.tipo = tipos[i]
		salida.tamaño = Vector2(ancho, alto_salida)
		add_child(salida, true)
		salida.global_position = divisiones.to_global(Vector2(centros[i], 0))
		salida.elegida.connect(al_elegir_salida)
		salidas.append(salida)


func elegir_tipos(cantidad : int) -> Array[TipoDeSala.Tipo]:
	var sin_tienda : Array[TipoDeSala.Tipo] = tipos_disponibles.filter(func(tipo): return tipo != TipoDeSala.Tipo.TIENDA)
	var tipos : Array[TipoDeSala.Tipo] = []
	if sin_tienda.is_empty():
		sin_tienda = tipos_disponibles
	for i in cantidad:
		tipos.append(sin_tienda.pick_random())
	if tipos_disponibles.has(TipoDeSala.Tipo.TIENDA) and cantidad > 0 and randf() < chance_tienda:
		tipos[randi_range(0, cantidad - 1)] = TipoDeSala.Tipo.TIENDA
	return tipos


func obtener_divisiones() -> DivisionesPachinko:
	return cargador.obtener_divisiones() if cargador else null


func al_elegir_salida(salida : SalidaDeNivel) -> void:
	if eleccion_hecha:
		return
	eleccion_hecha = true
	nivel_elegido.emit(salida.tipo)
