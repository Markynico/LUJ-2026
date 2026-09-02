class_name Reliquia
extends EfectoReliquia

@export var nombre : String = ""
@export var rareza : Rareza.Nivel = Rareza.Nivel.COMUN
@export_multiline var descripcion : String = ""
@export var icono : Texture2D:
	set(valor):
		icono = valor
		emit_changed()
##efectos genericos que se suman a los hooks propios del script de la reliquia
@export var efectos : Array[EfectoReliquia] = []

@export_group("Catalogo")
##si puede aparecer a la venta en la tienda
@export var en_tienda : bool = true
##si se muestra en la coleccion
@export var en_coleccion : bool = true

@export_group("Desbloqueo")
##condiciones que deben cumplirse todas para desbloquear la reliquia, vacio = desbloqueada de entrada
@export var condiciones_desbloqueo : Array[CondicionDesbloqueo] = []


func descripcion_para_mostrar() -> String:
	var texto : String = descripcion
	var extra : String
	for efecto in efectos:
		if efecto:
			extra = efecto.texto_extra()
			if not extra.is_empty():
				texto += "
" + extra
	return texto


func fuentes() -> Array:
	var resultado : Array = [self]
	for efecto in efectos:
		if efecto:
			resultado.append(efecto)
	return resultado
