@tool
class_name CargadorDeNivel
extends Node2D

signal nivel_construido

##nivel que se construye al iniciar, si esta vacio se usan las formas que ya son hijas del nodo
@export var nivel : NivelData:
	set(valor):
		if nivel and nivel.changed.is_connected(mostrar_vista_previa):
			nivel.changed.disconnect(mostrar_vista_previa)
		nivel = valor
		if nivel:
			nivel.changed.connect(mostrar_vista_previa)
		mostrar_vista_previa()
##escenas de formas disponibles
@export var escenas_formas : Dictionary[String, PackedScene] = {
	"rectangulo": preload("uid://cformarect0a1"),
	"circulo": preload("uid://cformacirc0a1"),
	"path": preload("uid://cformabe000a1"),
	"obstaculo_rectangulo": preload("uid://cobstrect00a1"),
	"obstaculo_circulo": preload("uid://cobstcirc00a1"),
}
##escena que envuelve a una forma para moverla por un recorrido
@export var escena_recorrido : PackedScene = preload("uid://crecorrido00a1")
##escena con los divisores de la parte de abajo
@export var escena_divisiones : PackedScene = preload("uid://cdivisiones0a1")
##estructura que define la zona jugable, si esta vacia se busca en el arbol
@export var estructura : EstructuraDeNivel
##distancia de los divisores al borde inferior de la zona jugable
@export var margen_inferior_divisiones : float = 0.0
##niveles entre los que se elige al azar cuando no hay nivel asignado, si esta vacio usa la carpeta
@export var niveles_aleatorios : Array[NivelData] = []
##carpeta de donde se cargan los niveles cuando la lista esta vacia
@export_dir var carpeta_niveles : String = "res://niveles"
##niveles que deben pasar antes de poder repetir el mismo
@export var niveles_sin_repetir : int = 2

var historial_niveles : Array[NivelData] = []


func _ready() -> void:
	if Engine.is_editor_hint():
		mostrar_vista_previa()
	else:
		construir_nivel_elegido()


func construir_nivel_elegido() -> void:
	var elegido : NivelData = nivel if nivel else elegir_nivel()
	if elegido:
		construir_nivel(elegido)


func elegir_nivel() -> NivelData:
	var disponibles : Array[NivelData] = niveles_aleatorios if not niveles_aleatorios.is_empty() else cargar_carpeta()
	var candidatos : Array[NivelData] = disponibles.filter(func(dato : NivelData) -> bool: return not historial_niveles.has(dato))
	var elegido : NivelData
	if disponibles.is_empty():
		return null
	if candidatos.is_empty():
		candidatos = disponibles
	elegido = candidatos.pick_random()
	historial_niveles.append(elegido)
	while historial_niveles.size() > niveles_sin_repetir:
		historial_niveles.pop_front()
	return elegido


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


func mostrar_vista_previa() -> void:
	if not Engine.is_editor_hint() or not is_inside_tree():
		return
	if es_raiz_editada():
		acomodar_divisiones(null)
		return
	limpiar_formas_sin_dueño()
	if nivel:
		instanciar_formas(nivel)
		aplicar_divisiones(nivel)


func es_raiz_editada() -> bool:
	return owner == null


func limpiar_formas_sin_dueño() -> void:
	for raiz in obtener_raices_de_formas():
		if raiz.owner == null:
			remove_child(raiz)
			raiz.queue_free()


func obtener_formas() -> Array[Node2D]:
	var formas : Array[Node2D] = []
	var forma : Node2D
	for hijo in get_children():
		if hijo is MovimientoPorPath:
			forma = hijo.obtener_forma()
			if forma:
				formas.append(forma)
		elif hijo.has_method("obtener_datos"):
			formas.append(hijo)
	return formas


func obtener_raices_de_formas() -> Array[Node2D]:
	var raices : Array[Node2D] = []
	for hijo in get_children():
		if hijo is MovimientoPorPath or hijo.has_method("obtener_datos"):
			raices.append(hijo)
	return raices


func limpiar_formas() -> void:
	for raiz in obtener_raices_de_formas():
		remove_child(raiz)
		raiz.queue_free()


func construir_nivel(datos_nivel : NivelData, dueño : Node = null) -> void:
	limpiar_formas()
	instanciar_formas(datos_nivel, dueño)
	aplicar_divisiones(datos_nivel)
	nivel_construido.emit()


func obtener_divisiones() -> DivisionesPachinko:
	for hijo in get_children():
		if hijo is DivisionesPachinko:
			return hijo
	return null

func aplicar_divisiones(datos_nivel : NivelData) -> void:
	var divisiones : DivisionesPachinko = obtener_divisiones()
	if not divisiones:
		divisiones = escena_divisiones.instantiate()
		add_child(divisiones, true)
	acomodar_divisiones(datos_nivel)


func acomodar_divisiones(datos_nivel : NivelData) -> void:
	var divisiones : DivisionesPachinko = obtener_divisiones()
	var estructura_activa : EstructuraDeNivel = obtener_estructura()
	var zona : Rect2
	if not divisiones:
		return
	if estructura_activa:
		zona = estructura_activa.zona_jugable()
		divisiones.global_position = Vector2(zona.position.x, zona.end.y - margen_inferior_divisiones)
		divisiones.ancho_total = zona.size.x
	elif datos_nivel:
		divisiones.position = datos_nivel.posicion_divisiones
		divisiones.ancho_total = datos_nivel.ancho_divisiones


func obtener_estructura() -> EstructuraDeNivel:
	if estructura:
		return estructura
	if not is_inside_tree():
		return null
	if Engine.is_editor_hint():
		return buscar_estructura(get_tree().edited_scene_root) if get_tree().edited_scene_root else null
	return buscar_estructura(get_tree().root)


func buscar_estructura(nodo : Node) -> EstructuraDeNivel:
	var encontrada : EstructuraDeNivel
	if nodo is EstructuraDeNivel:
		return nodo
	for hijo in nodo.get_children():
		encontrada = buscar_estructura(hijo)
		if encontrada:
			return encontrada
	return null


func instanciar_formas(datos_nivel : NivelData, dueño : Node = null) -> void:
	var forma : Node2D
	for datos in datos_nivel.formas:
		forma = crear_forma(datos.tipo, dueño)
		forma.aplicar_datos(datos)
		if datos.recorrido:
			agregar_recorrido(forma, dueño).aplicar_datos(datos)


func crear_forma(tipo : String, dueño : Node = null) -> Node2D:
	var forma : Node2D = escenas_formas[tipo].instantiate()
	add_child(forma, true)
	if dueño:
		forma.owner = dueño
	return forma


func agregar_recorrido(forma : Node2D, dueño : Node = null) -> MovimientoPorPath:
	var recorrido : MovimientoPorPath = escena_recorrido.instantiate()
	var posicion_global : Vector2 = forma.global_position
	forma.get_parent().remove_child(forma)
	add_child(recorrido, true)
	recorrido.global_position = posicion_global
	recorrido.seguidor.add_child(forma)
	forma.position = Vector2.ZERO
	if dueño:
		recorrido.owner = dueño
		dueño.set_editable_instance(recorrido, true)
		forma.owner = dueño
	return recorrido


func quitar_recorrido(recorrido : MovimientoPorPath, dueño : Node = null) -> Node2D:
	var forma : Node2D = recorrido.obtener_forma()
	var posicion_global : Vector2 = forma.global_position
	recorrido.seguidor.remove_child(forma)
	remove_child(recorrido)
	recorrido.queue_free()
	add_child(forma, true)
	forma.global_position = posicion_global
	if dueño:
		forma.owner = dueño
	return forma


func obtener_recorrido(forma : Node2D) -> MovimientoPorPath:
	var seguidor : Node = forma.get_parent()
	if seguidor is PathFollow2D and seguidor.get_parent() is MovimientoPorPath:
		return seguidor.get_parent()
	return null


func exportar_nivel(nombre : String) -> NivelData:
	var datos_nivel : NivelData = NivelData.new()
	var divisiones : DivisionesPachinko
	datos_nivel.nombre = nombre
	for raiz in obtener_raices_de_formas():
		datos_nivel.formas.append(raiz.obtener_datos())
	divisiones = obtener_divisiones()
	if divisiones:
		datos_nivel.posicion_divisiones = divisiones.position
		datos_nivel.ancho_divisiones = divisiones.ancho_total
	return datos_nivel
