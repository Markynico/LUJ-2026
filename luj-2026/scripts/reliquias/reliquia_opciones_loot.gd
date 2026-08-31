class_name ReliquiaOpcionesLoot
extends Reliquia

##opciones de reliquia que ofrece la sala de loot
@export var opciones : int = 3


func al_obtener(game_manager : GameManager) -> void:
	ReliquiasManager.opciones_loot = maxi(ReliquiasManager.opciones_loot, opciones)
