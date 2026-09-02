class_name DificultadRun
extends Resource

@export var nombre : String = ""
##texto del pergamino al pasar el mouse por el icono, vacio = se arma solo con los numeros de la dificultad
@export_multiline var descripcion : String = ""
##icono del boton en el selector de dificultad
@export var icono : Texture2D
##color del borde cuando la dificultad esta seleccionada
@export var color_seleccion : Color = Color.WHITE
##escala visual del icono en el selector, para emparejar las cabezas a ojo
@export var escala_icono : float = 1.0
##orden de la dificultad, para condiciones de "tal dificultad o mayor"
@export var rango : int = 0
##porcentaje de puntos requerido en el primer nivel, puede superar 1.0
@export_range(0.0, 1.0, 0.01, "or_greater") var porcentaje_inicial : float = 0.25
##porcentaje de puntos requerido en el ultimo nivel, puede superar 1.0
@export_range(0.0, 1.0, 0.01, "or_greater") var porcentaje_final : float = 0.7
##exponente de la curva de dificultad, 1 = lineal, mas alto = exponencial
@export var exponente_curva : float = 1.0
##niveles ganados necesarios para ganar la run
@export var niveles_para_ganar : int = 10
##multiplicador de los precios de tienda y comidas
@export var multiplicador_precios : float = 1.0
@export_group("Chances de sala")
##peso de las salas de loot al sortear cada salida
@export_range(0.0, 1.0, 0.05) var chance_loot : float = 0.25
##probabilidad de que aparezca una tienda entre las salidas
@export_range(0.0, 1.0, 0.05) var chance_tienda : float = 0.25
##salas minimas entre una tienda y la siguiente
@export_range(0, 20, 1) var salas_entre_tiendas : int = 3
##salas minimas entre una sala de loot y la siguiente
@export_range(0, 20, 1) var salas_entre_loots : int = 3
@export_group("")


func porcentaje_para(niveles_jugados : float) -> float:
	var progreso : float = 1.0
	if niveles_para_ganar > 1:
		progreso = clampf(niveles_jugados / float(niveles_para_ganar - 1), 0.0, 1.0)
	return lerpf(porcentaje_inicial, porcentaje_final, 1.0 - pow(1.0 - progreso, exponente_curva))


func exigencia_promedio() -> float:
	return (porcentaje_inicial + porcentaje_final) * 0.5


func descripcion_para_mostrar(referencia : DificultadRun = null) -> String:
	var multiplicador_meta : float = 1.0
	var multiplicador_precio : float = multiplicador_precios
	if not descripcion.is_empty():
		return descripcion
	if referencia and referencia.exigencia_promedio() > 0.0:
		multiplicador_meta = exigencia_promedio() / referencia.exigencia_promedio()
	if referencia and referencia.multiplicador_precios > 0.0:
		multiplicador_precio = multiplicador_precios / referencia.multiplicador_precios
	return "%d salas para ganar la run.
Meta de puntos %s.
Precios %s." % [niveles_para_ganar, resaltar("x%.1f" % multiplicador_meta), resaltar("x%.1f" % multiplicador_precio)]


func resaltar(texto : String) -> String:
	return "[color=#%s]%s[/color]" % [color_seleccion.to_html(false), texto]
