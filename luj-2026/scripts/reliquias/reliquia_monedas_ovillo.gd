class_name ReliquiaMonedasOvillo
extends Reliquia

##tipos de ovillo cuyas monedas se multiplican
@export var tipos_objetivo : Array[OvilloBase] = []
##multiplicador de monedas para los tipos objetivo
@export var multiplicador : float = 2.0


func multiplicador_monedas(tipo_ovillo : OvilloBase) -> float:
	if tipo_ovillo in tipos_objetivo:
		return multiplicador
	return 1.0
