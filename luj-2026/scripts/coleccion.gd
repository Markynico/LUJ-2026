class_name Coleccion
extends Control

##reliquias que muestra la coleccion
@export var pool_reliquias : Array[Reliquia] = []
##comidas que muestra la coleccion
@export var pool_comidas : Array[PelotitaBase] = []
##escala de las tarjetas en la grilla
@export var escala_tarjeta : float = 0.5
##tamaño base de la tarjeta
@export var tamaño_tarjeta : Vector2 = Vector2(500, 600)
##escena de la tarjeta
@export var escena_tarjeta : PackedScene = preload("uid://u6k76f6lyw8y")
##escena del menu a la que vuelve el boton
@export_file("*.tscn") var escena_menu : String = "uid://c30ry4xehty4"

@export_group("Nodos")
@export var grilla_reliquias : GridContainer
@export var grilla_comidas : GridContainer
@export var boton_volver : Button
@export var foco : FocoTarjetas


func _ready() -> void:
	boton_volver.pressed.connect(volver_al_menu)
	poblar_grilla(grilla_reliquias, pool_reliquias)
	poblar_grilla(grilla_comidas, pool_comidas)


func poblar_grilla(grilla : GridContainer, items : Array) -> void:
	var ordenados : Array = items.filter(func(item : Resource) -> bool: return item != null)
	ordenados.sort_custom(func(a : Resource, b : Resource) -> bool: return rareza_de(a) < rareza_de(b))
	for item in ordenados:
		crear_tarjeta(grilla, item)


func rareza_de(item : Resource) -> int:
	if "rareza" in item:
		return item.rareza
	return 0


func crear_tarjeta(grilla : GridContainer, item : Resource) -> void:
	var envoltura : Control = Control.new()
	var tarjeta : Tarjeta = escena_tarjeta.instantiate()
	envoltura.custom_minimum_size = tamaño_tarjeta * escala_tarjeta
	tarjeta.size = tamaño_tarjeta
	tarjeta.scale = Vector2.ONE * escala_tarjeta
	tarjeta.recurso = item
	tarjeta.clickeada.connect(al_click_tarjeta.bind(tarjeta))
	envoltura.add_child(tarjeta)
	grilla.add_child(envoltura)


func al_click_tarjeta(tarjeta : Tarjeta) -> void:
	foco.abrir(tarjeta)


func volver_al_menu() -> void:
	Transicion.cambiar_escena(escena_menu)
