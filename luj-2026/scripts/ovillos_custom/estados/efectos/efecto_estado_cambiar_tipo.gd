class_name EfectoEstadoCambiarTipo
extends EfectoEstadoOvillo

##tipo al que pasa el ovillo cuando recibe el estado, opcional
@export var tipo_al_aplicar : OvilloBase
##tipo al que pasa el ovillo cuando pierde el estado, opcional
@export var tipo_al_quitar : OvilloBase


func al_aplicar(ovillo : Ovillo) -> void:
	if tipo_al_aplicar:
		ovillo.cambiar_tipo(tipo_al_aplicar)


func al_quitar(ovillo : Ovillo) -> void:
	if tipo_al_quitar:
		ovillo.cambiar_tipo(tipo_al_quitar)
