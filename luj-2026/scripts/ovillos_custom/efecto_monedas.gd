class_name EfectoMonedas
extends EfectosOvillo

func al_recibir_impacto(ovillo: Ovillo):
	Global.actualizar_monedas(ovillo.obtener_monedas())
