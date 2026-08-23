class_name EfectoReboteNormal
extends EfectoEspejismo


func impactar_con_objeto(pelotita : BolaDePelos ,objeto_a_impactar : Node2D):
	rebote_simple(pelotita, objeto_a_impactar)
