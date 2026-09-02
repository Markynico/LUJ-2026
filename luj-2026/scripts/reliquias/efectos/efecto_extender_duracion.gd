class_name EfectoExtenderDuracion
extends EfectoReliquia

enum Que { CATNIP, ORO, MECHA, ESTADOS_OVILLO }

const CLAVES : Dictionary = {
	Que.CATNIP: "catnip",
	Que.ORO: "oro",
	Que.MECHA: "mecha",
	Que.ESTADOS_OVILLO: "estados_ovillo",
}

##que duracion se extiende: el frenesi del catnip, el doble de monedas del ovillo de oro, la mecha de los explosivos o los tiros que duran los estados de ovillo
@export var que : Que = Que.CATNIP
##por cuanto se multiplica la duracion
@export var multiplicador : float = 2.0


func multiplicador_duracion(clave : String) -> float:
	if clave == CLAVES[que]:
		return multiplicador
	return 1.0
