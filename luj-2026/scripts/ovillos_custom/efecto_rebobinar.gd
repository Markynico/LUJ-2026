class_name  EfectoRebobinar
extends EfectosOvillo

func al_recibir_impacto(ovillo: Ovillo):
	var bola : BolaDePelos = ovillo.bola_que_impacto
	var pelotita : PelotitaBase = bola.tipo_pelotita if bola else Global.ultima_pelotita_disparada
	if not pelotita:
		return
	AudioManager.reproducir_sfx(EfectoDeSonido.Tipo.REBOBINAR)
	ovillo.rebobinar_bola.emit()
	Global.agregar_pelotita_al_cargador(pelotita)
