class_name EfectoReliquia
extends Resource


func evento(nombre : String, contexto : Dictionary) -> void:
	pass


func al_obtener(game_manager : GameManager) -> void:
	evento("al_obtener", {"game_manager": game_manager})


func al_empezar_nivel(game_manager : GameManager) -> void:
	evento("al_empezar_nivel", {"game_manager": game_manager})


func al_romper_ovillo(ovillo : Ovillo) -> void:
	evento("al_romper_ovillo", {"ovillo": ovillo})


func al_preparar_disparo(datos : DatosDisparo) -> void:
	evento("al_preparar_disparo", {"datos": datos})


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
	evento("al_explotar", {"explosion": explosion})


func al_rebotar(game_manager : GameManager) -> void:
	evento("al_rebotar", {"game_manager": game_manager})


func al_disparar(game_manager : GameManager) -> void:
	evento("al_disparar", {"game_manager": game_manager})


func al_terminar_nivel(game_manager : GameManager, gano : bool, limpio : bool) -> void:
	evento("al_terminar_nivel", {"game_manager": game_manager, "gano": gano, "limpio": limpio})


func al_perder_bola(bola : BolaDePelos) -> void:
	evento("al_perder_bola", {"bola": bola})


func multiplicador_velocidad_escupida() -> float:
	return 1.0


func escupida_instantanea() -> bool:
	return false


func al_spawnear_ovillo(ovillo : Ovillo) -> void:
	evento("al_spawnear_ovillo", {"ovillo": ovillo})


func multiplicador_duracion(que : String) -> float:
	return 1.0
