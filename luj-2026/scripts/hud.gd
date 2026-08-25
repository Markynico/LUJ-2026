extends Control

@export var game_manager : GameManager
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	actualizar_bolas_restantes(game_manager.bolas_restantes)
	game_manager.bola_usada.connect(actualizar_bolas_restantes)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func actualizar_bolas_restantes(cantidad : int) -> void:
	$BolasRestantes.text = "Bolas de pelo restantes: " + str(cantidad)
	
