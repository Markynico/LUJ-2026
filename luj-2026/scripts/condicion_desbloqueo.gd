class_name CondicionDesbloqueo
extends Resource

##contador de Progreso que tiene que alcanzar la cantidad
@export_enum("runs_jugadas", "runs_ganadas", "runs_ganadas_en_dificultad", "niveles_ganados", "niveles_perdidos", "niveles_limpios", "ovillos_rotos", "ovillos_rotos_de_tipo", "bolas_disparadas", "monedas_conseguidas", "monedas_gastadas", "items_comprados", "reliquias_adquiridas", "curas_compradas", "reliquias_de_loot", "reliquia_desbloqueada") var contador : String = "runs_jugadas"
##valor que debe alcanzar el contador
@export var cantidad : int = 1
##tipo de ovillo que cuenta cuando el contador es ovillos_rotos_de_tipo
@export var ovillo_objetivo : OvilloBase
##dificultad minima cuando el contador es runs_ganadas_en_dificultad
@export var dificultad_objetivo : DificultadRun
##reliquia o comida que tiene que estar desbloqueada cuando el contador es reliquia_desbloqueada
@export var reliquia_objetivo : Resource
