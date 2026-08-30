@icon("res://iconos_custom/ammunition.svg")
class_name CargadorManager
extends Node

@export var game_manager : GameManager
@export var pelotita_normal : PelotitaBase
#var cargador : Array[PelotitaBase] #probando, lo saco x ahora pq creo q prefiero usar el cargador de global

func _ready() -> void: #TODO arreglar bug de q tengo q hacer click para q se vean las primeras pelotitas
	Global.eligio_una_comida.connect(_on_eligio_una_comida)
	if game_manager:
		game_manager.nivel_reiniciado.connect(crear_cargador_de_pelotitas)
	#crear_cargador_inicial() #solo con pelotitas normales
	crear_cargador_de_pelotitas()


func _on_eligio_una_comida():
	crear_cargador_de_pelotitas()

#func crear_cargador_inicial():
	#cargador.clear()
	#for i in game_manager.bolas_maximas - 1:
		#cargador.append(pelotita_normal)
	#Global.actualizar_cargador_pelotitas(cargador) #ahora si, siempre un cargador de 6 pelotitas / lo q valga el maximo


#para q se cree un array de pelotitas que de verdad puedo tirar, 4 normales + las q tenga segun las comidas elegidas y todo de forma aleatoria
func crear_cargador_de_pelotitas():
	Global.cargador_de_pelotitas.clear()
	for i in game_manager.bolas_maximas:
		if Global.comidas_elegidas.is_empty():
			print("como no hay comidas elegidas, seguramente recien emmpezo el juego o hay un bug :p, crear cargador con pelotita normal")
			Global.agregar_pelotita_al_cargador(pelotita_normal)
		else: #sino ya elegimos almenos una comida
			var pelotita_aleatoria = Global.comidas_elegidas.pick_random() #random segun las comidas q elegimos
			Global.agregar_pelotita_al_cargador(pelotita_aleatoria)
	Global.cargador_de_pelotitas.shuffle() #reordeno el cargador como a godot le pinte
	Global.cargador_pelotitas_actualizado.emit()
	#Global.actualizar_cargador_pelotitas(cargador) #ahora si, siempre un cargador de 6 pelotitas / lo q valga el maximo


func agregar_pelotita_al_cargador(): #TODO para que el ovillo violeta funcione con esto pero creo q conviene hacerlo con una funcion a global
	#q pelotita?
	#cargador.append(pelotitanueva)
	#y avisar q se actualizo para q el hud tambien se entere
	#Global.actualizar_cargador_pelotitas
	pass
