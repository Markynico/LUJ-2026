class_name PelotitaEspejismo
extends PelotitaBase

#probando pelotitas con efectos propios

var contador_impactos : int = 0
var pelotita_duplicada : bool = false

func impactar_con_objeto(pelotita : BolaDePelos ,objeto_a_impactar : Node2D): #probando
	contador_impactos += 1
	if contador_impactos >2 and not pelotita_duplicada:
		print("DUPLICAR PELOTITA")
		var nueva_pelotita : BolaDePelos = pelotita.duplicate()
		pelotita.add_child(nueva_pelotita) #ta malisimo esto pero era pa probar
		pelotita_duplicada = true
