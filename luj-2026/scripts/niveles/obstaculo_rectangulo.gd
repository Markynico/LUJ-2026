@tool
class_name ObstaculoRectangulo
extends FormaRectangulo


func obtener_datos() -> FormaData:
	var datos : FormaData = super()
	datos.tipo = "obstaculo_rectangulo"
	return datos


func permite_anillos() -> bool:
	return false


func _validate_property(propiedad : Dictionary) -> void:
	if propiedad.name in ["anillos_interiores", "anillos_exteriores", "separacion_anillos"]:
		propiedad.usage = PROPERTY_USAGE_NO_EDITOR
