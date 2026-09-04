extends Node2D

##monedas con las que arranca la prueba
@export var monedas : int = 9999
##clip de la musica interactiva que suena en la tienda
@export var clip_musica : String = "Michinko Tienda Loop"

@export_group("Nodos")
@export var tienda : SalaTienda


func _ready() -> void:
	Global.actualizar_monedas(monedas - Global.monedas)
	AudioManager.reproducir_musica(AudioManager.musica_juego)
	AudioManager.cambiar_clip.call_deferred(clip_musica)
	if tienda:
		tienda.continuar_pedido.connect(get_tree().reload_current_scene)
