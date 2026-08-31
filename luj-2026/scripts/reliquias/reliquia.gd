class_name Reliquia
extends Resource

@export var nombre : String = ""
@export var rareza : Rareza.Nivel = Rareza.Nivel.COMUN
@export_multiline var descripcion : String = ""
@export var icono : Texture2D:
	set(valor):
		icono = valor
		emit_changed()


func al_obtener(game_manager : GameManager) -> void:
	pass


func al_empezar_nivel(game_manager : GameManager) -> void:
	pass


func al_romper_ovillo(ovillo : Ovillo) -> void:
	pass


func al_preparar_disparo(datos : DatosDisparo) -> void:
	pass


func multiplicador_puntos(tipo_ovillo : OvilloBase) -> float:
	return 1.0
