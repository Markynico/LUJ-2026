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
	var normal : Vector2 = pelotita.normal_de_contacto(objeto_a_impactar)
	var fuerza : float = fuerza_rebote
	pelotita.separar_del_contacto(objeto_a_impactar)
	if objeto_a_impactar is Ovillo:
		fuerza += objeto_a_impactar.tipo_ovillo.rebote_extra #para q se sume el rebote de la pelotita + el rebote del ovillo (si es q corresponde)
	if objeto_a_impactar.has_method("recibir_impacto"):
		objeto_a_impactar.recibir_impacto()
	pelotita.apply_central_impulse(normal * fuerza)
