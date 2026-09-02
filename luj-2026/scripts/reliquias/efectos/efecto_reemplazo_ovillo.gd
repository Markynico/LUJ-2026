class_name EfectoReemplazoOvillo
extends EfectoReliquia

##ovillo que se sustituye al spawnear, tambien cuenta si el ovillo se contabiliza como este
@export var ovillo_a_reemplazar : OvilloBase
##ovillo que aparece en su lugar
@export var ovillo_reemplazo : OvilloBase
##probabilidad en porcentaje de reemplazar cada ovillo
@export_range(0.0, 100.0) var probabilidad : float = 100.0


func reemplazar_ovillo(tipo_ovillo : OvilloBase) -> OvilloBase:
	if not ovillo_a_reemplazar or not ovillo_reemplazo or not tipo_ovillo:
		return tipo_ovillo
	if tipo_ovillo != ovillo_a_reemplazar and tipo_ovillo.contar_como != ovillo_a_reemplazar:
		return tipo_ovillo
	if randf() * 100.0 > probabilidad:
		return tipo_ovillo
	return ovillo_reemplazo
