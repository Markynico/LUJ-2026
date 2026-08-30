class_name Rareza
extends RefCounted

enum Nivel { COMUN, RARO, EPICO, LEGENDARIO }

const NOMBRES : Array[String] = ["Común", "Raro", "Épico", "Legendario"]
const COLORES : Array[Color] = [Color("12a13aff"), Color("0036d6ff"), Color("8800ffff"), Color("ff6f00ff")]
const PRECIOS_RELIQUIAS : Array[int] = [50, 80, 120, 200]
const PRECIOS_COMIDAS : Array[int] = [30, 50, 80, 130]


static func nombre_de(nivel : Nivel) -> String:
	return NOMBRES[clampi(nivel, 0, NOMBRES.size() - 1)]


static func color_de(nivel : Nivel) -> Color:
	return COLORES[clampi(nivel, 0, COLORES.size() - 1)]


static func precio_de(item : Resource) -> int:
	var tabla : Array[int] = PRECIOS_COMIDAS
	if item is Reliquia:
		tabla = PRECIOS_RELIQUIAS
	return tabla[clampi(item.rareza, 0, tabla.size() - 1)]
