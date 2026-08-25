class_name Reliquia
extends Resource

@export var nombre : String = ""
@export_multiline var descripcion : String = ""
@export var icono : Texture2D:
	set(valor):
		icono = valor
		emit_changed()


func al_obtener(_game_manager : GameManager) -> void:
	pass


func al_empezar_nivel(game_manager : GameManager) -> void:
	pass


func al_romper_ovillo(ovillo : Ovillo) -> void:
	pass
