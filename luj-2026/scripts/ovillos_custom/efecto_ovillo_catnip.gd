class_name  EfectoCatnip
extends EfectosOvillo

func al_recibir_impacto(ovillo: Ovillo):
	ovillo.get_tree().call_group("ovillos", "duplicar_recompensas")
	print("FRENESÍ")
	await ovillo.get_tree().create_timer(3).timeout
	if is_instance_valid(ovillo):
		ovillo.get_tree().call_group("ovillos", "fin_duplicar")
