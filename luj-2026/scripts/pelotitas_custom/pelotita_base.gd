class_name PelotitaBase
extends Resource

@export var nombre : String = ""
##descripcion que se muestra en la tarjeta
@export_multiline var descripcion : String = ""
##textura o sprite de la pelotita
@export var textura : Texture2D

##colores para la estela q deja la pelotita al moverse
@export var colores_estela : Gradient

##imagen q se va a mostrar en el selector de comidas, la idea es q una pelotita este asociada a una comida si no me equivoco no?
@export var imagen_comida_asociada : Texture2D

#@export var multiplicador_monedas : int = 1 #si queremos que la pelotita multiplique las monedas del ovillo, perooo me parece q lo voy a meter en un efecto no aca
@export var efectos: Array[EfectosPelotita] #ahora ta aca adentro pq me mezclaba q esten separados
