class_name DificultadRun
extends Resource

@export var nombre : String = ""
##icono del boton en el selector de dificultad
@export var icono : Texture2D
##color del borde cuando la dificultad esta seleccionada
@export var color_seleccion : Color = Color.WHITE
##escala visual del icono en el selector, para emparejar las cabezas a ojo
@export var escala_icono : float = 1.0
##orden de la dificultad, para condiciones de "tal dificultad o mayor"
@export var rango : int = 0
##porcentaje de puntos requerido en el primer nivel
@export_range(0.0, 1.0) var porcentaje_inicial : float = 0.25
##porcentaje de puntos requerido en el ultimo nivel
@export_range(0.0, 1.0) var porcentaje_final : float = 0.7
##exponente de la curva de dificultad, 1 = lineal, mas alto = exponencial
@export var exponente_curva : float = 1.0
##niveles ganados necesarios para ganar la run
@export var niveles_para_ganar : int = 10
##multiplicador de los precios de tienda y comidas
@export var multiplicador_precios : float = 1.0


func porcentaje_para(niveles_jugados : float) -> float:
	var progreso : float = 1.0
	if niveles_para_ganar > 1:
		progreso = clampf(niveles_jugados / float(niveles_para_ganar - 1), 0.0, 1.0)
	return lerpf(porcentaje_inicial, porcentaje_final, pow(progreso, exponente_curva))
