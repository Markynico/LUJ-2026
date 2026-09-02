class_name EfectosPelotita #en realidad es una comida
extends Resource


#@export var cantidad_rebotes : int
##impulso extra que recibe la pelotita al golpear un ovillo, ademas del rebote fisico; contra paredes y obstaculos no aplica
@export var fuerza_rebote : float = 200
@export var nombre_comida : String 
#@export var imagen_bola_de_pelos : Texture2D

###imagen q se va a mostrar en el selector de comidas, la idea es q una pelotita este asociada a una comida si no me equivoco no?
#@export var imagen_comida_asociada : Texture2D

##Funcion q despues los demas efectos van a sobrescribir aplicando sus propios efectos, rebotes, y demas [br]
##Se llama a la funcion cuando la pelotita impacte con algo
func impactar_con_objeto(pelotita : BolaDePelos ,objeto_a_impactar : Node2D):
	rebote_simple(pelotita, objeto_a_impactar) #asi se usaria si queremos q la pelotita al impactar simplemente rebote y nada mas
	pass

##no es necesario que se sobre escriba, pero la dejo aca por si queremos evitar escribir mil veces la misma funcion para un simple rebote
func rebote_simple(pelotita : BolaDePelos ,objeto_a_impactar : Node2D):
	var normal : Vector2 = pelotita.normal_de_contacto(objeto_a_impactar)
	var extra : float = 0.0
	pelotita.separar_del_contacto(objeto_a_impactar)
	if objeto_a_impactar is Ovillo:
		extra = (fuerza_rebote + objeto_a_impactar.tipo_ovillo.rebote_extra) * ReliquiasManager.multiplicador_rebote()
	if objeto_a_impactar.has_method("recibir_impacto"):
		objeto_a_impactar.recibir_impacto(pelotita)
	pelotita.rebotar(normal, extra)

func al_crearse(pelotita : BolaDePelos):
	pass
