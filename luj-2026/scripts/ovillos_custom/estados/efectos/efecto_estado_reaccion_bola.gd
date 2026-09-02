class_name EfectoEstadoReaccionBola
extends EfectoEstadoOvillo

##tipos de bola a los que reacciona, vacio = todas
@export var bolas : Array[PelotitaBase] = []
##si esta prendido reacciona a las bolas que NO estan en la lista
@export var invertir : bool = false
##si el ovillo se rompe con el impacto
@export var romper : bool = true
##si la bola rebota contra el ovillo o lo atraviesa
@export var rebotar : bool = true
##si el impacto gasta una carga del estado
@export var gastar_carga : bool = false
##si el impacto quita el estado
@export var quitar_estado : bool = false


func reacciona_a(tipo_bola : PelotitaBase) -> bool:
	if bolas.is_empty():
		return true
	return (tipo_bola in bolas) != invertir


func resolver_impacto(ovillo : Ovillo, tipo_bola : PelotitaBase, resultado : ResultadoImpacto) -> void:
	if not reacciona_a(tipo_bola):
		return
	resultado.romper = romper
	resultado.rebotar = rebotar
	if gastar_carga and estado:
		resultado.gastar_carga.append(estado)
	if quitar_estado and estado:
		resultado.quitar.append(estado)
