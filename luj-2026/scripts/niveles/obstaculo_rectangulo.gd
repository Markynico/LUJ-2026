@tool
class_name ObstaculoRectangulo
extends FormaRectangulo


func obtener_datos() -> FormaData:
	var datos : FormaData = super()
	datos.tipo = "obstaculo_rectangulo"
	return datos
