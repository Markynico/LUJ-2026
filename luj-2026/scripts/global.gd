extends Node

var monedas : int = 0
var puntos : int = 0
var comidas_elegidas : Array[EfectosPelotita]
#@export var bolas_de_pelo_existentes : Array[EfectosPelotita] = [EfectoReboteNormal.new(), EfectoEspejismo.new()] #por si necesitamos q todos los objetos conozcan a los efectos de bola de pelo


signal monedas_cambiadas(monedas : int)
signal puntos_cambiados(puntos : int)
signal eligio_una_comida

func actualizar_monedas(valor):
	monedas += valor
	monedas_cambiadas.emit(monedas)

func actualizar_puntos(valor):
	puntos += valor
	puntos_cambiados.emit(puntos)


func actualizar_comidas_elegidas(comida_nueva : EfectosPelotita):
	comidas_elegidas.append(comida_nueva)
	eligio_una_comida.emit() #para avisarle al game manager q obtenga comidas_elegidas de este script

func get_comidas():
	return comidas_elegidas
