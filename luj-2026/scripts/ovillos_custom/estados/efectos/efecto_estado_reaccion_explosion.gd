class_name EfectoEstadoReaccionExplosion
extends EfectoEstadoOvillo

##si el ovillo se rompe cuando lo alcanza una explosion
@export var romper : bool = false
##si la explosion gasta una carga del estado
@export var gastar_carga : bool = false
##si la explosion quita el estado
@export var quitar_estado : bool = false


func resolver_explosion(ovillo : Ovillo, resultado : ResultadoImpacto) -> void:
	resultado.romper = romper
	if gastar_carga and estado:
		resultado.gastar_carga.append(estado)
	if quitar_estado and estado:
		resultado.quitar.append(estado)
