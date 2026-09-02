class_name Reliquia
extends Resource

@export var nombre : String = ""
@export var rareza : Rareza.Nivel = Rareza.Nivel.COMUN
@export_multiline var descripcion : String = ""
@export var icono : Texture2D:
	set(valor):
		icono = valor
		emit_changed()

@export_group("Desbloqueo")
##condiciones que deben cumplirse todas para desbloquear la reliquia, vacio = desbloqueada de entrada
@export var condiciones_desbloqueo : Array[CondicionDesbloqueo] = []


func descripcion_para_mostrar() -> String:
	return descripcion


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
