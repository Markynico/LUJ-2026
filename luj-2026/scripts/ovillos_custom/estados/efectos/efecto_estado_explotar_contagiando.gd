class_name EfectoEstadoExplotarContagiando
extends EfectoEstadoOvillo

##estado que reparte la explosion de un ovillo que tiene este estado, vacio = este mismo estado
@export var estado_a_aplicar : EstadoOvillo
##si la explosion ademas rompe los ovillos que alcanza
@export var romper_ovillos : bool = false


func al_explotar(ovillo : Ovillo, explosion : Explosion) -> void:
	explosion.estado_a_aplicar = estado_a_aplicar if estado_a_aplicar else estado
	explosion.rompe_ovillos = romper_ovillos
