class_name EfectoIgnea
extends EfectosPelotita

@export var impactos_para_duplicar : int = 3
@export var tipo_efecto_bomba : OvilloBase

func impactar_con_objeto(pelotita : BolaDePelos ,objeto_a_impactar : Node2D):
	rebote_simple(pelotita, objeto_a_impactar)
	#pelotita.contador_rebotes += 1
	if pelotita.contador_rebotes == impactos_para_duplicar:
		#print("ENTRO A HACER EXPLOSIVOOOOO")
		if objeto_a_impactar is Ovillo:
			print("ENTRO A IMPACTAR EXPLOSIVO")
			objeto_a_impactar.convertir_explosivo(objeto_a_impactar, tipo_efecto_bomba)
		pelotita.contador_rebotes = 0
