class_name ReliquiaDVD
extends Reliquia


func al_obtener(game_manager : GameManager) -> void:
	ReliquiasManager.bolas_atraviesan = true


func al_preparar_disparo(datos : DatosDisparo) -> void:
	datos.gravedad = Vector2.ZERO
	datos.rebotes = 0
