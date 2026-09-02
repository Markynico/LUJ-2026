@tool
class_name SpawnOvillo
extends Node2D

##escena del ovillo que aparece en este punto al correr el juego
@export var escena_ovillo : PackedScene = preload("uid://dy3jqoayfdkwm")
##radio de respaldo de la vista previa si el ovillo no tiene collider circular
@export var radio_vista_previa : float = 8.0
@export var color_vista_previa : Color = Color(1.0, 0.8, 0.2, 0.8)

@export var tipo_ovillos : Array[OvilloBase]

var radio_colision : float = 0.0
var anulado : bool = false:
	set(valor):
		anulado = valor
		queue_redraw()


func _ready() -> void:
	if Engine.is_editor_hint() or anulado:
		return
	instanciar_ovillo()


func _draw() -> void:
	if Engine.is_editor_hint() and not anulado:
		draw_circle(Vector2.ZERO, obtener_radio_colision(), color_vista_previa)


func obtener_radio_colision() -> float:
	var ovillo : Node
	var colision : CollisionShape2D
	if radio_colision > 0.0:
		return radio_colision
	radio_colision = radio_vista_previa
	if escena_ovillo:
		ovillo = escena_ovillo.instantiate()
		colision = ovillo.get_node_or_null("CollisionShape2D")
		if colision and colision.shape is CircleShape2D:
			radio_colision = colision.shape.radius
		ovillo.free()
	return radio_colision


func instanciar_ovillo() -> void:
	if not escena_ovillo:
		return
	var tipo : OvilloBase = ReliquiasManager.reemplazo_para(elegir_ovillo())
	var ovillo : Ovillo= escena_ovillo.instantiate()
	ovillo.tipo_ovillo = tipo
	add_child(ovillo)
	

func elegir_ovillo() -> OvilloBase:
	var valor_spawn_total : float = 0.0
	
	for ovillo in tipo_ovillos:
		valor_spawn_total += ovillo.valor_spawn * ReliquiasManager.multiplicador_spawn_para(ovillo)
		#Calcula el valor total de todos los tipos de ovillo
	
	var valor_aleatorio : float = randf_range(0.0, valor_spawn_total)
	
	var valor_a_elegir : float = 0.0
	
	#vuelve a recorrer el arreglo y chequea el avance del valor
	#de los ovillos con el numero aleatorio elegido
	for ovillo in tipo_ovillos:
		valor_a_elegir += ovillo.valor_spawn * ReliquiasManager.multiplicador_spawn_para(ovillo)
		if valor_aleatorio <= valor_a_elegir:
			return ovillo
	
#Condicion de corte si falla
	return tipo_ovillos[0]
