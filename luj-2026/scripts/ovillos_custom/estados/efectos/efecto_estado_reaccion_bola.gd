class_name EfectoEstadoReaccionBola
extends EfectoEstadoOvillo

enum Bola { REBOTA, ATRAVIESA, SE_FRENA }

##tipos de bola a los que reacciona, vacio = todas; ojo: si la bola a su vez aplica este estado, usa la opcion de abajo en vez de la lista, porque referenciarla desde aca arma un ciclo que Godot no puede cargar
@export var bolas : Array[PelotitaBase] = []
##reacciona a las bolas que aplican este mismo estado, por ejemplo la bola de hielo para el congelado
@export var bolas_que_aplican_este_estado : bool = false
##si esta prendido reacciona a las bolas que NO estan en la lista
@export var invertir : bool = false
##si el ovillo se rompe con el impacto
@export var romper : bool = true
##que hace la bola: rebota normal, atraviesa el ovillo sin frenarse ni desviarse, o se frena sin impulso de rebote
@export var bola : Bola = Bola.REBOTA
##si el impacto gasta una carga del estado
@export var gastar_carga : bool = false
##si el gato lanzado gasta uno de sus impactos al chocar este ovillo
@export var cuenta_para_el_gato : bool = true
##si el impacto quita el estado
@export var quitar_estado : bool = false


func reacciona_a(tipo_bola : PelotitaBase) -> bool:
	var coincide : bool = tipo_bola in bolas
	if bolas.is_empty() and not bolas_que_aplican_este_estado:
		return true
	if bolas_que_aplican_este_estado and tipo_bola and estado:
		for efecto in tipo_bola.efectos:
			if efecto is EfectoComidaAplicarEstado and efecto.estado and efecto.estado.nombre == estado.nombre:
				coincide = true
	return coincide != invertir


func resolver_impacto(ovillo : Ovillo, tipo_bola : PelotitaBase, resultado : ResultadoImpacto) -> void:
	if not reacciona_a(tipo_bola):
		return
	resultado.romper = romper
	resultado.rebotar = bola == Bola.REBOTA
	resultado.atravesar = bola == Bola.ATRAVIESA
	resultado.cuenta_para_el_gato = cuenta_para_el_gato
	if gastar_carga and estado:
		resultado.gastar_carga.append(estado)
	if quitar_estado and estado:
		resultado.quitar.append(estado)
