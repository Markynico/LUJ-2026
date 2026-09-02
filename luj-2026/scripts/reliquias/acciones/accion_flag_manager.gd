class_name AccionFlagManager
extends AccionReliquia

##flag del ReliquiasManager que se prende
@export var flag : EfectoFlagManager.Flag = EfectoFlagManager.Flag.EXPLOSION_INSTANTANEA
##valor que se le pone al flag
@export var valor : bool = true


func ejecutar(contexto : Dictionary) -> bool:
	ReliquiasManager.set(EfectoFlagManager.PROPIEDADES[flag], valor)
	return true
