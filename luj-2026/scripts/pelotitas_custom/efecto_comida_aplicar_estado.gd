class_name EfectoComidaAplicarEstado
extends EfectosPelotita

##estado que se aplica al ovillo que toca la bola
@export var estado : EstadoOvillo
##probabilidad en porcentaje de aplicarlo en cada impacto
@export_range(0.0, 100.0) var probabilidad : float = 100.0
##tipos de ovillo a los que aplica, vacio = todos
@export var tipos_objetivo : Array[OvilloBase] = []
##si esta prendido, el primer toque solo aplica el estado y rebota; la bola rompe unicamente ovillos que ya tenian el estado
@export var romper_solo_si_ya_lo_tenia : bool = false


func aplica_a(ovillo : Ovillo) -> bool:
	if not estado or not ovillo.tipo_ovillo:
		return false
	if not tipos_objetivo.is_empty() and not ovillo.tipo_ovillo in tipos_objetivo and not ovillo.tipo_ovillo.contar_como in tipos_objetivo:
		return false
	return true


func impactar_con_objeto(pelotita : BolaDePelos, objeto_a_impactar : Node2D):
	var romper : bool = true
	if romper_solo_si_ya_lo_tenia and objeto_a_impactar is Ovillo and aplica_a(objeto_a_impactar):
		romper = objeto_a_impactar.tiene_estado(estado.nombre)
	rebote_simple(pelotita, objeto_a_impactar, romper)


func al_impactar_ovillo(pelotita : BolaDePelos, ovillo : Ovillo):
	if aplica_a(ovillo) and randf() * 100.0 <= probabilidad:
		ovillo.aplicar_estado(estado)
