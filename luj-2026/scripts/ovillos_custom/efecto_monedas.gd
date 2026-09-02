class_name EfectoMonedas
extends EfectosOvillo

##monedas base que da el ovillo al romperse, antes de multiplicadores de catnip, oro, estados y reliquias
@export var monedas : int = 1


func al_recibir_impacto(ovillo : Ovillo):
	Global.actualizar_monedas(ovillo.obtener_monedas(monedas))
