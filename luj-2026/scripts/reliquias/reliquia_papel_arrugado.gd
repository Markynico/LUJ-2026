class_name ReliquiaPapelArrugado
extends Reliquia


func descripcion_para_mostrar() -> String:
	var nombres : Array[String] = []
	var selector : SelectorDeNiveles
	if not GameManager.instancia_actual or not GameManager.instancia_actual.selector_niveles:
		return descripcion
	selector = GameManager.instancia_actual.selector_niveles
	for salida in selector.salidas:
		if is_instance_valid(salida):
			nombres.append(TipoDeSala.NOMBRES.get(salida.tipo, "?").capitalize())
	if nombres.is_empty():
		return descripcion
	nombres.sort()
	for indice in nombres.size():
		nombres[indice] = colorear_nombre(nombres[indice])
	return descripcion + "\n\nSalidas: " + ", ".join(nombres)


func colorear_nombre(nombre : String) -> String:
	for tipo in TipoDeSala.NOMBRES:
		if TipoDeSala.NOMBRES[tipo].capitalize() == nombre:
			return "[color=#%s]%s[/color]" % [Color(TipoDeSala.COLORES[tipo], 1.0).to_html(false), nombre]
	return nombre
