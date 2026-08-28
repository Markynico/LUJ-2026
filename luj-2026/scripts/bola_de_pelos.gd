@icon("res://iconos_custom/sphere.svg")
class_name BolaDePelos
extends RigidBody2D


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
	

func normal_de_contacto(objeto : Node2D) -> Vector2:
	var estado : PhysicsDirectBodyState2D = PhysicsServer2D.body_get_direct_state(get_rid())
	var normal : Vector2
	for i in estado.get_contact_count():
		if estado.get_contact_collider_object(i) == objeto:
			normal = estado.get_contact_local_normal(i)
			if normal.dot(global_position - estado.get_contact_local_position(i)) < 0.0:
				normal = -normal
			return normal
	return objeto.global_position.direction_to(global_position)

func separar_del_contacto(objeto : Node2D) -> void:
	var estado : PhysicsDirectBodyState2D = PhysicsServer2D.body_get_direct_state(get_rid())
	var radio : float = $CollisionShape2D.shape.radius
	var normal : Vector2
	var punto : Vector2
	for i in estado.get_contact_count():
		if estado.get_contact_collider_object(i) == objeto:
			punto = estado.get_contact_local_position(i)
			normal = normal_de_contacto(objeto)
			if (global_position - punto).length() < radio:
				estado.transform.origin = punto + normal * radio
				global_position = punto + normal * radio
			return

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
	#TODO aca agregaria un chekeo para subirle el pitch scale
	#algo tipo global.impactos_acumulados
	#y si acumula + 2 + 3 + 4 impactos le meto + pitch scale y suena como queriamos
	audio.play()


#eliminar la bola de pelos cuando sale de la pantalla
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
