class_name AccionOpcionesLoot
extends AccionReliquia

##opciones de reliquia que ofrece la sala de loot, se queda con el mayor
@export var opciones : int = 3


func ejecutar(contexto : Dictionary) -> bool:
	ReliquiasManager.opciones_loot = maxi(ReliquiasManager.opciones_loot, opciones)
	return true
