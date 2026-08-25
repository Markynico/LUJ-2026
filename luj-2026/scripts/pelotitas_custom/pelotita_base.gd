class_name PelotitaBase
extends Resource

@export var nombre : String = ""
##textura o sprite de la pelotita
@export var textura : Texture2D
##colores para la estela q deja la pelotita al moverse
@export var colores_estela : Gradient
#@export var multiplicador_monedas : int = 1 #si queremos que la pelotita multiplique las monedas del ovillo, perooo me parece q lo voy a meter en un efecto no aca
@export var efectos: Array[EfectosPelotita] #ahora ta aca adentro pq me mezclaba q esten separados
