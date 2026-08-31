@icon("res://iconos_custom/ammunition.svg")
class_name CargadorManager
extends Node

@export var game_manager : GameManager
@export var pelotita_normal : PelotitaBase #al final me convenia meter esto en el global


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
	#print("comidas elegidas vale: ", Global.comidas_elegidas)
	if Global.comidas_elegidas.is_empty():
		print("como no hay comidas elegidas, seguramente recien emmpezo el juego o hay un bug :p, crear car(gador con pelotita normal")
		Global.comidas_elegidas.append(pelotita_normal) #fuerzo a q la primer comida elegida sea la normal (ya probe setear con @export la normal pero por algun motivo no anda asiq lo hago por codigo aca)

	var ultima_comida : PelotitaBase = Global.comidas_elegidas.back() #para q siempre salga al menos UNA de la ultima comida q compraste
	Global.agregar_pelotita_al_cargador(ultima_comida)
	for i in game_manager.bolas_maximas - 1: #-1 pq le meti a la fuerza la ultima comida, si queremos q al comprar siempre sume 1 mas al cargador le sacamos el -1
		var pelotita_aleatoria = Global.comidas_elegidas.pick_random() #random segun las comidas q elegimos
		Global.agregar_pelotita_al_cargador(pelotita_aleatoria)

	Global.cargador_de_pelotitas.shuffle() #reordeno el cargador como a godot le pinte
	Global.cargador_pelotitas_actualizado.emit()
	#Global.actualizar_cargador_pelotitas(cargador) #ahora si, siempre un cargador de 6 pelotitas / lo q valga el maximo

#dale bocaaaaaaaaaaaaa
