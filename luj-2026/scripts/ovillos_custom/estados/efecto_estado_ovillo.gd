class_name EfectoEstadoOvillo
extends Resource

var estado : EstadoOvillo


func al_aplicar(ovillo : Ovillo) -> void:
	pass


func al_quitar(ovillo : Ovillo) -> void:
	pass


func resolver_impacto(ovillo : Ovillo, tipo_bola : PelotitaBase, resultado : ResultadoImpacto) -> void:
	pass


func resolver_explosion(ovillo : Ovillo, resultado : ResultadoImpacto) -> void:
	pass


func al_romperse(ovillo : Ovillo) -> void:
	pass


func al_rebotar_bola(ovillo : Ovillo, bola : BolaDePelos) -> void:
	pass


func modificar_puntaje(ovillo : Ovillo, puntos : int) -> int:
	return puntos


func modificar_monedas(ovillo : Ovillo, monedas : int) -> int:
	return monedas


func al_empezar_turno(ovillo : Ovillo) -> void:
	pass
