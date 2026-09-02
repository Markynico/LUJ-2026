class_name EfectoIgnea
extends EfectosPelotita

##impactos con ovillos que necesita para convertir uno en explosivo, sin importar rebotes con paredes u obstaculos en el medio
@export var impactos_para_duplicar : int = 3
@export var tipo_efecto_bomba : OvilloBase

func impactar_con_objeto(pelotita : BolaDePelos ,objeto_a_impactar : Node2D):
	rebote_simple(pelotita, objeto_a_impactar)
	if not objeto_a_impactar is Ovillo:
		return
	pelotita.impactos_ovillos += 1
	if pelotita.impactos_ovillos >= impactos_para_duplicar:
		pelotita.impactos_ovillos = 0
		objeto_a_impactar.convertir_explosivo(objeto_a_impactar, tipo_efecto_bomba)
