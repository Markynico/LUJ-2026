class_name SalaNormal
extends Node2D

##cargador donde se construye el nivel elegido
@export var cargador : CargadorDeNivel
##niveles entre los que se elige al azar, si esta vacio usa todos los de la carpeta de niveles
@export var niveles : Array[NivelData] = []
##carpeta de donde se cargan los niveles cuando la lista esta vacia
@export_dir var carpeta_niveles : String = "res://niveles"


func _ready() -> void:
	var nivel : NivelData = elegir_nivel()
	if cargador and nivel:
		cargador.construir_nivel(nivel)


func elegir_nivel() -> NivelData:
	var disponibles : Array[NivelData] = niveles if not niveles.is_empty() else cargar_carpeta()
	return disponibles.pick_random() if not disponibles.is_empty() else null


func cargar_carpeta() -> Array[NivelData]:
	var encontrados : Array[NivelData] = []
	var recurso : Resource
	for archivo in DirAccess.get_files_at(carpeta_niveles):
		if archivo.get_extension() != "tres":
			continue
		recurso = load(carpeta_niveles.path_join(archivo))
		if recurso is NivelData:
			encontrados.append(recurso)
	return encontrados
