class_name EfectoDeSonido
extends Resource

enum Tipo {
	REBOTE,
	ROMPER_OVILLO,
	ROMPER_OVILLO_MONEDA,
	LANZAR_GATO,
	ELEGIR_SALIDA,
	BOTON_UI,
	ESTANDARTE_ABRIR,
	ESTANDARTE_CERRAR,
	COMPRAR,
}

##tipo de efecto con el que se pide desde el codigo
@export var tipo : Tipo = Tipo.REBOTE
##sonidos posibles, se elige uno al azar en cada reproduccion
@export var streams : Array[AudioStream] = []
##volumen en decibeles
@export_range(-40.0, 20.0, 0.5) var volumen_db : float = 0.0
##maximo de reproducciones simultaneas de este efecto
@export_range(1, 32, 1) var limite_simultaneos : int = 8
##tono minimo del rango aleatorio
@export_range(0.5, 2.0, 0.01) var pitch_minimo : float = 1.0
##tono maximo del rango aleatorio
@export_range(0.5, 2.0, 0.01) var pitch_maximo : float = 1.0


func stream_aleatorio() -> AudioStream:
	if streams.is_empty():
		return null
	return streams.pick_random()
