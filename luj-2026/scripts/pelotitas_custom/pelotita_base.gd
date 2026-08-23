class_name PelotitaBase
extends Resource

##textura o sprite de la pelotita
@export var textura : Texture2D
##colores para la estela q deja la pelotita al moverse
@export var colores_estela : Gradient
@export var cantidad_rebotes : int
@export var fuerza_rebote : float

##Funcion q despues las demas pelotitas van a sobrescribir aplicando sus propios efectos, rebotes, y demas [br]
##Se llama a la funcion cuando la pelotita impacte con algo
func impactar_con_objeto(pelotita : BolaDePelos ,objeto_a_impactar : Node2D):
	#rebote_simple(pelotita, objeto_a_impactar) #asi se usaria si queremos q la pelotita al impactar simplemente rebote y nada mas
	pass

##no es necesario que se sobre escriba, pero la dejo aca por si queremos evitar escribir mil veces la misma funcion para un simple rebote
func rebote_simple(pelotita : BolaDePelos ,objeto_a_impactar : Node2D):
	var normal = pelotita.global_position.direction_to(objeto_a_impactar.global_position)
	#var fuerza = objeto.get_fuerza_rebote() ?? idea
	pelotita.apply_central_impulse(-normal * fuerza_rebote)
	if objeto_a_impactar.has_method("recibir_impacto"):
		objeto_a_impactar.recibir_impacto()
