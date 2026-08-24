@icon("res://iconos_custom/sphere.svg")
class_name BolaDePelos
extends RigidBody2D

#a futuro capaz meto un enum de TIPO DE BOLA DE PELOS y q segun ese enum se instancie y se setee toooda la info q necesito (?

@export_group("TIPO")
@export var tipo_pelotita : PelotitaBase #TODO revisar si de verdad lo necesito aca o directamente hacer export vars aca en el nodo

@export_group("NODOS")
@export var sprite_bola: Sprite2D
@export var estela_movimiento : EstelaMovimiento
@export var audio : AudioStreamPlayer


var fue_duplicada : bool = false #probando, seguro lo saco de aca
var contador_rebotes : int = 0

func _ready() -> void:
	estela_movimiento.gradient = tipo_pelotita.colores_estela
	sprite_bola.texture = tipo_pelotita.textura

func _on_body_shape_entered(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	if body is BolaDePelos: #evito rebote con otras bolas de pelos
		return
	for efecto in tipo_pelotita.efectos:
		efecto.impactar_con_objeto(self, body)
		sonido_rebote()


func duplicar_pelotita():
	if fue_duplicada: #para solo duplicarla una sola vez
		return
	var pelotita_nueva : BolaDePelos = duplicate()
	pelotita_nueva.fue_duplicada = true #evito q la duplicada tambien se duplique
	get_parent().add_child(pelotita_nueva)
	fue_duplicada = true

func sonido_rebote():
	audio.play()


#eliminar la bola de pelos cuando sale de la pantalla
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
