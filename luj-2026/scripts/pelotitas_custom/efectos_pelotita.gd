class_name EfectosPelotita
extends Resource


#@export var cantidad_rebotes : int
##fuerza de rebote, ojo q necesita un valor alto, con 200 minimo anda bien
@export var fuerza_rebote : float = 200

##Funcion q despues los demas efectos van a sobrescribir aplicando sus propios efectos, rebotes, y demas [br]
##Se llama a la funcion cuando la pelotita impacte con algo
func impactar_con_objeto(pelotita : BolaDePelos ,objeto_a_impactar : Node2D):
	#rebote_simple(pelotita, objeto_a_impactar) #asi se usaria si queremos q la pelotita al impactar simplemente rebote y nada mas
	pass

##no es necesario que se sobre escriba, pero la dejo aca por si queremos evitar escribir mil veces la misma funcion para un simple rebote
func rebote_simple(pelotita : BolaDePelos ,objeto_a_impactar : Node2D):
	var normal = pelotita.global_position.direction_to(objeto_a_impactar.global_position)
	#var fuerza = objeto.get_fuerza_rebote() ?? idea
	pelotita.apply_central_impulse(-normal * fuerza_rebote)
	if objeto_a_impactar is Ovillo:
		objeto_a_impactar.recibir_impacto()
