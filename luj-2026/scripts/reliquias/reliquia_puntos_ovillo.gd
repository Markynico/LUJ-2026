class_name ReliquiaPuntosOvillo
extends Reliquia

##tipos de ovillo cuyos puntos se multiplican
@export var tipos_objetivo : Array[OvilloBase] = []
##multiplicador de puntos para los tipos objetivo
@export var multiplicador : float = 2.0


func multiplicador_puntos(tipo_ovillo : OvilloBase) -> float:
	if tipo_ovillo in tipos_objetivo:
		return multiplicador
	return 1.0
