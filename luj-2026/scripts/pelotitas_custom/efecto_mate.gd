class_name EfectoMate
extends EfectosPelotita

func al_crearse(pelotita : BolaDePelos):
	await pelotita.get_tree().process_frame #pruebo aver si eso lo soluciona
	await pelotita.get_tree().process_frame
	await pelotita.get_tree().process_frame
	pelotita.duplicar_pelotita()
