extends Node

signal reliquia_obtenida(reliquia : Reliquia)

var obtenidas : Array[Reliquia] = []
var game_manager_actual : GameManager
var explosion_instantanea : bool = false
var catnip_stackeable : bool = false
var opciones_loot : int = 1
var salidas_reveladas : bool = false
var bolas_atraviesan : bool = false
var ultima_ofrecida : Reliquia


func obtener(reliquia : Reliquia) -> void:
	if not reliquia:
		return
	obtenidas.append(reliquia)
	if not is_instance_valid(game_manager_actual):
		game_manager_actual = null
	for fuente in reliquia.fuentes():
		fuente.al_obtener(game_manager_actual)
	reliquia_obtenida.emit(reliquia)


func fuentes() -> Array:
	var resultado : Array = []
	for reliquia in obtenidas:
		resultado.append_array(reliquia.fuentes())
	return resultado


func al_empezar_nivel(game_manager : GameManager) -> void:
	game_manager_actual = game_manager
	for reliquia in fuentes():
		reliquia.al_empezar_nivel(game_manager)


func al_preparar_disparo(datos : DatosDisparo) -> void:
	for reliquia in fuentes():
		reliquia.al_preparar_disparo(datos)


func multiplicador_puntos_para(tipo_ovillo : OvilloBase) -> float:
	var multiplicador : float = 1.0
	for reliquia in fuentes():
		multiplicador *= reliquia.multiplicador_puntos(tipo_ovillo)
	return multiplicador


func multiplicador_monedas_para(tipo_ovillo : OvilloBase) -> float:
	var multiplicador : float = 1.0
	for reliquia in fuentes():
		multiplicador *= reliquia.multiplicador_monedas(tipo_ovillo)
	return multiplicador


func reemplazo_para(tipo_ovillo : OvilloBase) -> OvilloBase:
	var resultado : OvilloBase = tipo_ovillo
	for reliquia in fuentes():
		resultado = reliquia.reemplazar_ovillo(resultado)
	return resultado


func multiplicador_spawn_para(tipo_ovillo : OvilloBase) -> float:
	var multiplicador : float = 1.0
	for reliquia in fuentes():
		multiplicador *= reliquia.multiplicador_spawn(tipo_ovillo)
	return multiplicador


func descuento_tienda() -> float:
	var descuento : float = 0.0
	for reliquia in fuentes():
		descuento = maxf(descuento, reliquia.descuento_tienda())
	return descuento


func multiplicador_rebote() -> float:
	var multiplicador : float = 1.0
	for reliquia in fuentes():
		multiplicador *= reliquia.multiplicador_rebote()
	return multiplicador


func multiplicador_dificultad() -> float:
	var multiplicador : float = 1.0
	for reliquia in fuentes():
		multiplicador *= reliquia.multiplicador_dificultad()
	return multiplicador


func al_explotar(explosion : Explosion) -> void:
	for reliquia in fuentes():
		reliquia.al_explotar(explosion)


func al_rebotar() -> void:
	for reliquia in fuentes():
		reliquia.al_rebotar(game_manager_actual)


func al_disparar() -> void:
	for reliquia in fuentes():
		reliquia.al_disparar(game_manager_actual)


func al_romper_ovillo(ovillo : Ovillo) -> void:
	for reliquia in fuentes():
		reliquia.al_romper_ovillo(ovillo)


func al_terminar_nivel(game_manager : GameManager, gano : bool, limpio : bool) -> void:
	for reliquia in fuentes():
		reliquia.al_terminar_nivel(game_manager, gano, limpio)


func al_perder_bola(bola : BolaDePelos) -> void:
	for reliquia in fuentes():
		reliquia.al_perder_bola(bola)


func multiplicador_velocidad_escupida() -> float:
	var multiplicador : float = 1.0
	for reliquia in fuentes():
		multiplicador *= reliquia.multiplicador_velocidad_escupida()
	return multiplicador


func escupida_instantanea() -> bool:
	for reliquia in fuentes():
		if reliquia.escupida_instantanea():
			return true
	return false
