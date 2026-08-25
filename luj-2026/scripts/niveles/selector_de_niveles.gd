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

var salidas : Array[SalidaDeNivel] = []


func _ready() -> void:
	if cargador:
		cargador.nivel_construido.connect(preparar_salidas)
	preparar_salidas.call_deferred()


func preparar_salidas() -> void:
	var divisiones := obtener_divisiones()
	if not divisiones:
		return
	divisiones.divisiones_intermedias = randi_range(divisores_minimos, divisores_maximos)
	colocar_salidas.call_deferred()


func colocar_salidas() -> void:
	for salida in salidas:
		salida.queue_free()
	salidas.clear()
	var divisiones := obtener_divisiones()
	if not divisiones or not escena_salida or tipos_disponibles.is_empty():
		return
	var ancho := divisiones.ancho_de_hueco()
	for centro in divisiones.obtener_centros_de_huecos():
		var salida : SalidaDeNivel = escena_salida.instantiate()
		salida.tipo = tipos_disponibles.pick_random()
		salida.tamaño = Vector2(ancho, alto_salida)
		add_child(salida, true)
		salida.global_position = divisiones.to_global(Vector2(centro, 0))
		salida.elegida.connect(al_elegir_salida)
		salidas.append(salida)


func obtener_divisiones() -> DivisionesPachinko:
	return cargador.obtener_divisiones() if cargador else null


func al_elegir_salida(salida : SalidaDeNivel) -> void:
	nivel_elegido.emit(salida.tipo)
