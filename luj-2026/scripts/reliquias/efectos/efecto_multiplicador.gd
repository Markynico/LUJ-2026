class_name EfectoMultiplicador
extends EfectoReliquia

enum Que { PUNTOS, MONEDAS, SPAWN, REBOTE, DIFICULTAD }

##que valor se multiplica
@export var que : Que = Que.PUNTOS
##por cuanto
@export var multiplicador : float = 2.0
##tipos de ovillo a los que aplica, vacio = todos; solo cuenta para puntos, monedas y spawn
@export var tipos_objetivo : Array[OvilloBase] = []


func aplica(tipo_ovillo : OvilloBase) -> bool:
	return tipos_objetivo.is_empty() or tipo_ovillo in tipos_objetivo


func valor_para(objetivo : Que, tipo_ovillo : OvilloBase) -> float:
	if que == objetivo and aplica(tipo_ovillo):
		return multiplicador
	return 1.0


func multiplicador_puntos(tipo_ovillo : OvilloBase) -> float:
	return valor_para(Que.PUNTOS, tipo_ovillo)


func multiplicador_monedas(tipo_ovillo : OvilloBase) -> float:
	return valor_para(Que.MONEDAS, tipo_ovillo)


func multiplicador_spawn(tipo_ovillo : OvilloBase) -> float:
	return valor_para(Que.SPAWN, tipo_ovillo)


func multiplicador_rebote() -> float:
	return valor_para(Que.REBOTE, null)


func multiplicador_dificultad() -> float:
	return valor_para(Que.DIFICULTAD, null)


func al_preparar_disparo(datos : DatosDisparo) -> void:
	if que == Que.REBOTE:
		datos.fuerza_rebote *= multiplicador
