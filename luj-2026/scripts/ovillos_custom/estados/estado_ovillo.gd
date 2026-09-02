class_name EstadoOvillo
extends EfectoEstadoOvillo

@export var nombre : String = ""
@export_multiline var descripcion : String = ""
##textura que se dibuja sobre el ovillo mientras tiene el estado
@export var decoracion : Texture2D
##si esta prendido, el ovillo cambia su color base por el del estado mientras lo tiene
@export var cambiar_color : bool = false
##color que reemplaza al del ovillo mientras tiene el estado
@export var color : Color = Color.WHITE
##tiros que dura el estado, 0 = hasta que algo lo quite
@export var duracion_tiros : int = 0
##veces que puede gastarse una carga antes de quitarse, 0 = infinitas
@export var cargas : int = 0
##efectos genericos que componen el estado, ademas de los hooks propios del script
@export var efectos : Array[EfectoEstadoOvillo] = []

var tiros_restantes : int = 0
var cargas_restantes : int = 0


func fuentes() -> Array:
	var resultado : Array = [self]
	for efecto in efectos:
		if efecto:
			efecto.estado = self
			resultado.append(efecto)
	return resultado


func iniciar() -> void:
	estado = self
	tiros_restantes = roundi(duracion_tiros * ReliquiasManager.multiplicador_duracion_para("estados_ovillo")) if duracion_tiros > 0 else 0
	cargas_restantes = cargas


func gastar_carga() -> bool:
	if cargas <= 0:
		return false
	cargas_restantes -= 1
	return cargas_restantes <= 0


func pasar_turno() -> bool:
	if duracion_tiros <= 0:
		return false
	tiros_restantes -= 1
	return tiros_restantes <= 0
