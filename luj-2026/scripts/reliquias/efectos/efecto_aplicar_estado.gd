class_name EfectoAplicarEstado
extends EfectoReliquia

##estado que se aplica a los ovillos al aparecer
@export var estado : EstadoOvillo
##probabilidad en porcentaje de aplicarlo a cada ovillo
@export_range(0.0, 100.0) var probabilidad : float = 100.0
##tipos de ovillo a los que aplica, vacio = todos
@export var tipos_objetivo : Array[OvilloBase] = []


func al_spawnear_ovillo(ovillo : Ovillo) -> void:
	if not estado or not ovillo.tipo_ovillo:
		return
	if not tipos_objetivo.is_empty() and not ovillo.tipo_ovillo in tipos_objetivo and not ovillo.tipo_ovillo.contar_como in tipos_objetivo:
		return
	if randf() * 100.0 <= probabilidad:
		ovillo.aplicar_estado(estado)
