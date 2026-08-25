extends Control

@onready var bolas_restantes: Label = %BolasRestantes
@onready var monedas_label: Label = %Monedas

@export var game_manager : GameManager
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	actualizar_bolas_restantes(game_manager.bolas_restantes)
	game_manager.bola_usada.connect(actualizar_bolas_restantes)
	actualizar_monedas(Global.monedas)
	Global.monedas_cambiadas.connect(actualizar_monedas)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func actualizar_bolas_restantes(cantidad : int) -> void:
	bolas_restantes.text = "Bolas de pelo restantes: " + str(cantidad)

func actualizar_monedas(monedas : int):
	monedas_label.text = "Monedas: " + str(Global.monedas)
