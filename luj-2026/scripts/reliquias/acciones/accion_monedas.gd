class_name AccionMonedas
extends AccionReliquia

##monedas que se suman, negativo para restar
@export var monedas : int = 10


func ejecutar(contexto : Dictionary) -> bool:
	Global.actualizar_monedas(monedas)
	return true
