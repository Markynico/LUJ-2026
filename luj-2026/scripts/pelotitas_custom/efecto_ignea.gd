class_name EfectoIgnea
extends EfectosPelotita

##impactos con ovillos que necesita para convertir uno en explosivo, sin importar rebotes con paredes u obstaculos en el medio
@export var impactos_para_duplicar : int = 3
@export var tipo_efecto_bomba : OvilloBase

func impactar_con_objeto(pelotita : BolaDePelos ,objeto_a_impactar : Node2D):
	var convertir : bool = false
	if objeto_a_impactar is Ovillo:
		pelotita.impactos_ovillos += 1
		if pelotita.impactos_ovillos >= impactos_para_duplicar:
			pelotita.impactos_ovillos = 0
			convertir = objeto_a_impactar.activado and objeto_a_impactar.tipo_ovillo != ReliquiasManager.reemplazo_para(tipo_efecto_bomba)
	if convertir:
		objeto_a_impactar.convertir_explosivo(objeto_a_impactar, tipo_efecto_bomba)
		rebote_simple(pelotita, objeto_a_impactar, false)
	else:
		rebote_simple(pelotita, objeto_a_impactar)
