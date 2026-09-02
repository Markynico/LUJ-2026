class_name EfectoCubitoDeHielo
extends EfectosPelotita


func impactar_con_objeto(pelotita : BolaDePelos, objeto_a_impactar : Node2D):
	super(pelotita, objeto_a_impactar)


func al_impactar_ovillo(pelotita : BolaDePelos, ovillo : Ovillo):
	super(pelotita, ovillo)
