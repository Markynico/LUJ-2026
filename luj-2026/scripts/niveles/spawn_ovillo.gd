@tool
class_name SpawnOvillo
extends Node2D

##escena del ovillo que aparece en este punto al correr el juego
@export var escena_ovillo : PackedScene = preload("uid://dy3jqoayfdkwm")
##radio del circulito de vista previa en el editor
@export var radio_vista_previa : float = 8.0
@export var color_vista_previa : Color = Color(1.0, 0.8, 0.2, 0.8)

@export var tipo_ovillos : Array[OvilloBase]


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	instanciar_ovillo()


func _draw() -> void:
	if Engine.is_editor_hint():
		draw_circle(Vector2.ZERO, radio_vista_previa, color_vista_previa)


func instanciar_ovillo() -> void:
	if not escena_ovillo:
		return
	var tipo = elegir_ovillo()
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
