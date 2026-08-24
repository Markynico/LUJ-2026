class_name EfectoEspejismo #efecto espejismo
extends EfectosPelotita

##contador de impactos que necesita para duplicarse
@export var impactos_para_duplicar : int

func impactar_con_objeto(pelotita : BolaDePelos ,objeto_a_impactar : Node2D): #probando
	rebote_simple(pelotita, objeto_a_impactar)
	pelotita.contador_rebotes += 1 #ahora si, solucionao el bug, tenkiu attie
	if pelotita.contador_rebotes >= impactos_para_duplicar:
		#print("DUPLICAR PELOTITA")
		pelotita.call_deferred("duplicar_pelotita")
