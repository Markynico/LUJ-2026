class_name EfectoOvilloOro
extends EfectosOvillo

##segundos durante los que las monedas valen doble, las reliquias pueden extenderlo
@export var duracion : float = 5.0


func al_recibir_impacto(ovillo : Ovillo):
	ovillo.get_tree().call_group("ovillos", "duplicar_monedas")
	await ovillo.get_tree().create_timer(duracion * ReliquiasManager.multiplicador_duracion_para("oro")).timeout
	if is_instance_valid(ovillo):
		ovillo.get_tree().call_group("ovillos", "fin_duplicar_monedas")
