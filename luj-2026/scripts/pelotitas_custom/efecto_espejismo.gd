class_name EfectoEspejismo #efecto espejismo
extends EfectosPelotita

##contador de impactos que necesita para duplicarse
@export var impactos_para_duplicar : int
var contador_impactos : int = 0

func impactar_con_objeto(pelotita : BolaDePelos ,objeto_a_impactar : Node2D): #probando
	rebote_simple(pelotita, objeto_a_impactar)
	contador_impactos += 1
	if contador_impactos >= impactos_para_duplicar:
		print("DUPLICAR PELOTITA")
		pelotita.call_deferred("duplicar_pelotita")
		contador_impactos = 0
