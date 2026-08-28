@icon("res://iconos_custom/book.svg")
extends Node


signal monedas_cambiadas(monedas : int)
signal puntos_cambiados(puntos : int)
signal eligio_una_comida
signal cargador_pelotitas_actualizado #cuando disparo tambien llamo a esta signal

var monedas : int = 0
var puntos : int = 0

##aca pongamos los resource de todas las bolitas de pelo q existen (bueno de los efectos en realidad), no importa el orden pq despues uso otro array para elegir y ordenar
@export var bolas_de_pelo_existentes : Array[PelotitaBase] #en resumen todas las q existen

##las comidas q elegiste basicamente, se pueden repetir
var comidas_elegidas : Array[PelotitaBase] #INFO: es parecido a la de arriba, pero aca si se pueden repetir los valores, pq podemos tener 3 espejitos + 2 normmales + una de carne + una de choclo y otra de carne y otra de choclo, si como supiste q tengo sueño

var cargador_de_pelotitas : Array[PelotitaBase] #aca si, solo las q puede disparar 4 normales + las q haya en bolas_de_pelo_disponibles, perdonsisehacelioesqtengosueño


func actualizar_monedas(valor):
	monedas += valor
	monedas_cambiadas.emit(monedas)

func actualizar_puntos(valor):
	puntos += valor
	puntos_cambiados.emit(puntos)


func actualizar_comidas_elegidas(pelotita_nueva : PelotitaBase):
	print("global, elegimos una comida")
	comidas_elegidas.append(pelotita_nueva)
	eligio_una_comida.emit() #para avisarle al game manager q obtenga comidas_elegidas de este script

func get_comidas_elegidas():
	return comidas_elegidas

func actualizar_cargador_pelotitas(cargador_nuevo : Array[PelotitaBase]):
	cargador_de_pelotitas = cargador_nuevo
	cargador_pelotitas_actualizado.emit()

func get_cargador_de_pelotitas():
	return cargador_de_pelotitas
