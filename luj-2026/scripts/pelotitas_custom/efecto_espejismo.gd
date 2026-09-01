class_name EfectoEspejismo #efecto espejismo
extends EfectosPelotita

##contador de impactos que necesita para duplicarse
@export var impactos_para_duplicar : int

func impactar_con_objeto(pelotita : BolaDePelos ,objeto_a_impactar : Node2D): #probando
	rebote_simple(pelotita, objeto_a_impactar)
	if not objeto_a_impactar is Ovillo:
		return
	pelotita.impactos_ovillos += 1
	if pelotita.impactos_ovillos >= impactos_para_duplicar:
		pelotita.impactos_ovillos = 0
		pelotita.call_deferred("duplicar_pelotita")
