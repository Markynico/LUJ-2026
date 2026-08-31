class_name ReliquiaSpawnOvillo
extends Reliquia

##tipos de ovillo cuya probabilidad de spawn se multiplica
@export var tipos_objetivo : Array[OvilloBase] = []
##multiplicador de la probabilidad de spawn
@export var multiplicador : float = 1.25


func multiplicador_spawn(tipo_ovillo : OvilloBase) -> float:
	if tipo_ovillo in tipos_objetivo:
		return multiplicador
	return 1.0
