class_name AccionAplicarEstado
extends AccionReliquia

##estado que se aplica
@export var estado : EstadoOvillo
##si el hook trae un ovillo (al_romper_ovillo, al_spawnear_ovillo) se aplica solo a ese; si no, a todos los ovillos activos del nivel
@export var solo_al_ovillo_del_hook : bool = true
##probabilidad en porcentaje por ovillo
@export_range(0.0, 100.0) var probabilidad : float = 100.0


func ejecutar(contexto : Dictionary) -> bool:
	var ovillo : Ovillo = contexto.get("ovillo")
	var game_manager : GameManager = game_manager_de(contexto)
	var aplico : bool = false
	if not estado:
		return false
	if ovillo and solo_al_ovillo_del_hook:
		return aplicar(ovillo)
	if not game_manager:
		return false
	for otro in game_manager.get_tree().get_nodes_in_group("ovillos"):
		if otro.activado and aplicar(otro):
			aplico = true
	return aplico


func aplicar(ovillo : Ovillo) -> bool:
	if randf() * 100.0 > probabilidad:
		return false
	return ovillo.aplicar_estado(estado) != null
