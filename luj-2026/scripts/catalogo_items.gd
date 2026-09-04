class_name CatalogoItems
extends RefCounted

const CARPETA : String = "res://scripts/resources/"

static var reliquias_cargadas : Array[Reliquia] = []
static var comidas_cargadas : Array[PelotitaBase] = []
static var gatos_cargados : Array[DatosGato] = []
static var cargado : bool = false


static func cargar() -> void:
	var rutas : Array[String] = []
	var recurso : Resource
	if cargado:
		return
	cargado = true
	recorrer(CARPETA, rutas)
	rutas.sort()
	for ruta in rutas:
		recurso = load(ruta)
		if recurso is Reliquia:
			reliquias_cargadas.append(recurso)
		elif recurso is PelotitaBase:
			comidas_cargadas.append(recurso)
		elif recurso is DatosGato:
			gatos_cargados.append(recurso)
	gatos_cargados.sort_custom(func(a : DatosGato, b : DatosGato) -> bool: return a.orden < b.orden)


static func recorrer(carpeta : String, rutas : Array[String]) -> void:
	var directorio : DirAccess = DirAccess.open(carpeta)
	var nombre : String
	if not directorio:
		return
	directorio.list_dir_begin()
	nombre = directorio.get_next()
	while not nombre.is_empty():
		if directorio.current_is_dir():
			recorrer(carpeta.path_join(nombre), rutas)
		elif nombre.ends_with(".tres") or nombre.ends_with(".tres.remap"):
			rutas.append(carpeta.path_join(nombre.trim_suffix(".remap")))
		nombre = directorio.get_next()
	directorio.list_dir_end()


static func reliquias_en_tienda() -> Array:
	cargar()
	return reliquias_cargadas.filter(func(reliquia : Reliquia) -> bool: return reliquia.en_tienda)


static func reliquias_en_coleccion() -> Array:
	cargar()
	return reliquias_cargadas.filter(func(reliquia : Reliquia) -> bool: return reliquia.en_coleccion)


static func comidas_en_tienda() -> Array:
	cargar()
	return comidas_cargadas.filter(func(comida : PelotitaBase) -> bool: return comida.en_tienda)


static func comidas_en_coleccion() -> Array:
	cargar()
	return comidas_cargadas.filter(func(comida : PelotitaBase) -> bool: return comida.en_coleccion)


static func gatos() -> Array[DatosGato]:
	cargar()
	return gatos_cargados
