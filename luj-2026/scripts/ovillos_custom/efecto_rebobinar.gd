class_name  EfectoRebobinar
extends EfectosOvillo

func al_recibir_impacto(ovillo: Ovillo):
	var bola = ovillo.bola_que_impacto
	
	if bola:
		ovillo.rebobinar_bola.emit()
		Global.agregar_pelotita_al_cargador(bola.tipo_pelotita)
		print("EMITIDO")
