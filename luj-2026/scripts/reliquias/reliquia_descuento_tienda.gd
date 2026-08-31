class_name ReliquiaDescuentoTienda
extends Reliquia

##descuento normal de la tienda, 0.15 = 15%
@export var descuento : float = 0.15
##descuento cuando el dia del sistema es miercoles
@export var descuento_miercoles : float = 0.5


func descuento_tienda() -> float:
	if Time.get_datetime_dict_from_system().weekday == Time.WEEKDAY_WEDNESDAY:
		return descuento_miercoles
	return descuento
