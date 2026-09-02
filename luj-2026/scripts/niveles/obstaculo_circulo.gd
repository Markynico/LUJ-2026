@tool
class_name ObstaculoCirculo
extends FormaCirculo


func obtener_datos() -> FormaData:
	var datos : FormaData = super()
	datos.tipo = "obstaculo_circulo"
	return datos


func permite_anillos() -> bool:
	return false


func _validate_property(propiedad : Dictionary) -> void:
	if propiedad.name in ["anillos_interiores", "anillos_exteriores", "separacion_anillos"]:
		propiedad.usage = PROPERTY_USAGE_NO_EDITOR
