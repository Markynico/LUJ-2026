@icon("res://iconos_custom/sphere.svg")
class_name BolaDePelos
extends RigidBody2D

@export var fuerza_rebote : float = 350 #TODO, por ahora existe aca pero podria ser una propiedad del objeto en el cual rebota
@export var audio : AudioStreamPlayer
@export var tipo_pelotita : PelotitaBase
@export var estela_movimiento : EstelaMovimiento

func _ready() -> void:
	estela_movimiento.set_color_estela(tipo_pelotita.colores_estela)

func _on_body_shape_entered(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	if body is BolaDePelos: #evito rebote con otras bolas de pelos
		return
	tipo_pelotita.impactar_con_objeto(self, body)
	#impactar_con_objeto(body)

func impactar_con_objeto(objeto : Node):
	#por ahora se ejecuta el rebote clasico, pero aca meteria la logica para hacer ejecutar
	#el efecto de impacto segun la pelotita q sea
	#tipo_pelotita.impacto_con_objeto(objeto) algo asi seria
	var normal = global_position.direction_to(objeto.global_position)
	#var fuerza = objeto.get_fuerza_rebote() ?? idea
	apply_central_impulse(-normal * fuerza_rebote)
	audio.play()
	objeto.queue_free()
