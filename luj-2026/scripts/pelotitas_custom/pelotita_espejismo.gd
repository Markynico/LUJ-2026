class_name PelotitaEspejismo
extends PelotitaBase

#probando pelotitas con efectos propios

var contador_impactos : int = 0

func impactar_con_objeto(pelotita : BolaDePelos ,objeto_a_impactar : Node2D): #probando
	rebote_simple(pelotita, objeto_a_impactar)
	contador_impactos += 1
	if contador_impactos >3:
		print("DUPLICAR PELOTITA")
		pelotita.duplicar_pelotita()
		contador_impactos = 0
