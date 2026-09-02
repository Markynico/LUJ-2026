class_name  EfectoCatnip
extends EfectosOvillo

##segundos que dura el frenesi, las reliquias pueden extenderlo
@export var duracion : float = 3.0

func al_recibir_impacto(ovillo: Ovillo):
	AudioManager.reproducir_sfx(EfectoDeSonido.Tipo.CATNIP)
	ovillo.get_tree().call_group("ovillos", "duplicar_recompensas")
	await ovillo.get_tree().create_timer(duracion * ReliquiasManager.multiplicador_duracion_para("catnip")).timeout
	if is_instance_valid(ovillo):
		ovillo.get_tree().call_group("ovillos", "fin_duplicar")
