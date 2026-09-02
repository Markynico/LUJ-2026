class_name EfectoFlagManager
extends EfectoReliquia

enum Flag { EXPLOSION_INSTANTANEA, CATNIP_STACKEABLE, SALIDAS_REVELADAS, BOLAS_ATRAVIESAN }

const PROPIEDADES : Dictionary = {
	Flag.EXPLOSION_INSTANTANEA: "explosion_instantanea",
	Flag.CATNIP_STACKEABLE: "catnip_stackeable",
	Flag.SALIDAS_REVELADAS: "salidas_reveladas",
	Flag.BOLAS_ATRAVIESAN: "bolas_atraviesan",
}

##flag del ReliquiasManager que se prende al obtener la reliquia
@export var flag : Flag = Flag.EXPLOSION_INSTANTANEA


func al_obtener(game_manager : GameManager) -> void:
	ReliquiasManager.set(PROPIEDADES[flag], true)
