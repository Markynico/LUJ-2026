extends Node

var monedas : int = 0
var gato_elegido : DatosGato
var puntos : int = 0

signal monedas_cambiadas(monedas : int)
signal puntos_cambiados(puntos : int)

func actualizar_monedas(valor):
	monedas += valor
	monedas_cambiadas.emit(monedas)

func actualizar_puntos(valor):
	puntos += valor
	puntos_cambiados.emit(puntos)
