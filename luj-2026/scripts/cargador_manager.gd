@icon("res://iconos_custom/ammunition.svg")
class_name CargadorManager
extends Node

@export var game_manager : GameManager
var cargador : Array[PelotitaBase]

func _ready() -> void:
	Global.eligio_una_comida.connect(_on_eligio_una_comida)


func _on_eligio_una_comida():
	crear_cargador_de_pelotitas()


#TODO componente pasarlo al game manager
#para q se cree un array de pelotitas que de verdad puedo tirar, 4 normales + las q tenga segun las comidas elegidas y todo de forma aleatoria
func crear_cargador_de_pelotitas():
	for i in game_manager.bolas_maximas - 1:
		var pelotita_aleatoria = Global.comidas_elegidas.pick_random() #random segun las comidas q elegimos
		cargador.append(pelotita_aleatoria)
	cargador.shuffle() #reordeno el cargador como a godot le pinte
	Global.actualizar_cargador_pelotitas(cargador) #ahora si, siempre un cargador de 6 pelotitas / lo q valga el maximo


func agregar_pelotita_al_cargador(): #TODO para que el ovillo violeta funcione con esto
	#q pelotita?
	#cargador.append(pelotitanueva)
	#y avisar q se actualizo para q el hud tambien se entere
	#Global.actualizar_cargador_pelotitas
	pass
