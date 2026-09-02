class_name EfectoNoRompeOvillos
extends EfectosPelotita


func impactar_con_objeto(pelotita : BolaDePelos, objeto_a_impactar : Node2D):
	rebote_simple(pelotita, objeto_a_impactar, not objeto_a_impactar is Ovillo)
