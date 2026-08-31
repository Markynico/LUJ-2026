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
	return descripcion + "\n\nSalidas: " + ", ".join(nombres)
