class_name EfectoReliquia
extends Resource


func al_obtener(game_manager : GameManager) -> void:
	pass


func al_empezar_nivel(game_manager : GameManager) -> void:
	pass


func al_romper_ovillo(ovillo : Ovillo) -> void:
	pass


func al_preparar_disparo(datos : DatosDisparo) -> void:
	pass


func multiplicador_puntos(tipo_ovillo : OvilloBase) -> float:
	return 1.0


func multiplicador_spawn(tipo_ovillo : OvilloBase) -> float:
	return 1.0


func reemplazar_ovillo(tipo_ovillo : OvilloBase) -> OvilloBase:
	return tipo_ovillo


func multiplicador_monedas(tipo_ovillo : OvilloBase) -> float:
	return 1.0


func descuento_tienda() -> float:
	return 0.0


func multiplicador_dificultad() -> float:
	return 1.0


func multiplicador_rebote() -> float:
	return 1.0


func al_explotar(explosion : Explosion) -> void:
	pass


func al_rebotar(game_manager : GameManager) -> void:
	pass


func al_disparar(game_manager : GameManager) -> void:
	pass


func al_terminar_nivel(game_manager : GameManager, gano : bool, limpio : bool) -> void:
	pass


func al_perder_bola(bola : BolaDePelos) -> void:
	pass


func multiplicador_velocidad_escupida() -> float:
	return 1.0


func escupida_instantanea() -> bool:
	return false
