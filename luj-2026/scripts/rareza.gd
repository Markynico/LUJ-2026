class_name Rareza
extends RefCounted

enum Nivel { COMUN, RARO, EPICO, LEGENDARIO, MITICO }

const NOMBRES : Array[String] = ["Común", "Raro", "Épico", "Legendario", "Mítico"]
const COLORES : Array[Color] = [Color("12a13aff"), Color("0036d6ff"), Color("8800ffff"), Color("ff6f00ff"), Color("e01818ff")]
const PRECIOS_RELIQUIAS : Array[int] = [50, 80, 120, 200, 400]
const PRECIOS_COMIDAS : Array[int] = [30, 50, 80, 130, 260]


static func nombre_de(nivel : Nivel) -> String:
	return NOMBRES[clampi(nivel, 0, NOMBRES.size() - 1)]


static func color_de(nivel : Nivel) -> Color:
	return COLORES[clampi(nivel, 0, COLORES.size() - 1)]


static func precio_de(item : Resource) -> int:
	var tabla : Array[int] = PRECIOS_COMIDAS
	var multiplicador : float = 1.0
	if item is Reliquia:
		tabla = PRECIOS_RELIQUIAS
	if GameManager.dificultad_actual:
		multiplicador = GameManager.dificultad_actual.multiplicador_precios
	return roundi(tabla[clampi(item.rareza, 0, tabla.size() - 1)] * multiplicador)
