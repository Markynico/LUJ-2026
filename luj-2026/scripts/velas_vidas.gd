@tool
class_name VelasVidas
extends Node2D

##escena de cada vela
@export var escena_vela : PackedScene = preload("res://escenas/componentes/vela_vida.tscn")
##posicion de la primera vela
@export var origen : Vector2 = Vector2.ZERO:
	set(valor):
		origen = valor
		acomodar_vista_previa()
##desplazamiento entre una vela y la siguiente
@export var separacion : Vector2 = Vector2(60, 0):
	set(valor):
		separacion = valor
		acomodar_vista_previa()
##cantidad de velas de guia que se muestran solo en el editor
@export var velas_vista_previa : int = 3:
	set(valor):
		velas_vista_previa = maxi(valor, 0)
		crear_vista_previa()

var velas : Array[VelaVida] = []


func _ready() -> void:
	var game_manager : GameManager
	if Engine.is_editor_hint():
		crear_vista_previa()
		return
	game_manager = GameManager.instancia_actual
	if not game_manager:
		game_manager = get_tree().root.find_child("GameManager", true, false) as GameManager
	if not game_manager:
		return
	game_manager.vidas_cambiadas.connect(actualizar_velas)
	actualizar_velas(game_manager.vidas_actuales, game_manager.vidas_maximas)


func crear_vista_previa() -> void:
	if not Engine.is_editor_hint() or not is_inside_tree():
		return
	for hijo in get_children():
		remove_child(hijo)
		hijo.queue_free()
	for i in velas_vista_previa:
		add_child(escena_vela.instantiate())
	acomodar_vista_previa()


func acomodar_vista_previa() -> void:
	var hijos : Array[Node] = get_children()
	if not Engine.is_editor_hint() or not is_inside_tree():
		return
	for i in hijos.size():
		hijos[i].position = origen + separacion * i


func actualizar_velas(vidas_actuales : int, vidas_maximas : int) -> void:
	while velas.size() < vidas_maximas:
		agregar_vela()
	while velas.size() > vidas_maximas:
		quitar_vela()
	for i in velas.size():
		if i < vidas_actuales:
			velas[i].encender()
		else:
			velas[i].apagar()


func agregar_vela() -> void:
	var vela : VelaVida = escena_vela.instantiate()
	vela.position = origen + separacion * velas.size()
	add_child(vela)
	velas.append(vela)


func quitar_vela() -> void:
	var vela : VelaVida = velas.pop_back()
	vela.desaparecer()
