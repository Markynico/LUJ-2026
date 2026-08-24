@tool
class_name ObstaculoCirculo
extends FormaCirculo


func obtener_datos() -> FormaData:
	var datos := super()
	datos.tipo = "obstaculo_circulo"
	return datos
