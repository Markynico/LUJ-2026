class_name EfectosPelotita #en realidad es una comida
extends Resource


#@export var cantidad_rebotes : int
##impulso extra que recibe la pelotita al golpear un ovillo, ademas del rebote fisico; contra paredes y obstaculos no aplica
@export var fuerza_rebote : float = 200
#@export var imagen_bola_de_pelos : Texture2D

###imagen q se va a mostrar en el selector de comidas, la idea es q una pelotita este asociada a una comida si no me equivoco no?
#@export var imagen_comida_asociada : Texture2D

##Funcion q despues los demas efectos van a sobrescribir aplicando sus propios efectos, rebotes, y demas [br]
##Se llama a la funcion cuando la pelotita impacte con algo
func impactar_con_objeto(pelotita : BolaDePelos ,objeto_a_impactar : Node2D):
	rebote_simple(pelotita, objeto_a_impactar) #asi se usaria si queremos q la pelotita al impactar simplemente rebote y nada mas
	pass

##no es necesario que se sobre escriba, pero la dejo aca por si queremos evitar escribir mil veces la misma funcion para un simple rebote [br]
##si la comida tiene varios efectos, solo el primero que llega aca rebota y decide si rompe; los demas quedan como reaccion
func rebote_simple(pelotita : BolaDePelos ,objeto_a_impactar : Node2D, romper : bool = true):
	var normal : Vector2 = pelotita.normal_de_contacto(objeto_a_impactar)
	var extra : float = 0.0
	var resultado : ResultadoImpacto
	if not pelotita.registrar_rebote(objeto_a_impactar):
		return
	if objeto_a_impactar is Ovillo:
		extra = (fuerza_rebote + objeto_a_impactar.tipo_ovillo.rebote_extra) * ReliquiasManager.multiplicador_rebote()
		for efecto in pelotita.tipo_pelotita.efectos:
			efecto.al_impactar_ovillo(pelotita, objeto_a_impactar)
		if romper:
			objeto_a_impactar.recibir_impacto(pelotita)
			resultado = objeto_a_impactar.ultimo_resultado
		else:
			resultado = objeto_a_impactar.simular_impacto(pelotita.tipo_pelotita)
	elif objeto_a_impactar.has_method("recibir_impacto") and romper:
		objeto_a_impactar.recibir_impacto(pelotita)
	if resultado and resultado.atravesar:
		pelotita.add_collision_exception_with(objeto_a_impactar)
		pelotita.linear_velocity = pelotita.velocidad_entrante
		return
	pelotita.separar_del_contacto(objeto_a_impactar)
	if resultado and not resultado.rebotar:
		return
	pelotita.rebotar(normal, extra)
	if objeto_a_impactar is Ovillo:
		objeto_a_impactar.al_rebotar_bola(pelotita)

func al_crearse(pelotita : BolaDePelos):
	pass

##se llama justo antes de que el ovillo resuelva el impacto, asi lo que se le haga aca (por ejemplo un estado) cuenta para este golpe
func al_impactar_ovillo(pelotita : BolaDePelos, ovillo : Ovillo):
	pass
