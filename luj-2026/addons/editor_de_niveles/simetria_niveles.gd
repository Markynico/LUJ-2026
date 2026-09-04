@tool
class_name SimetriaNiveles
extends Node2D

const COLOR_EJE_H := Color(0.3, 0.85, 1.0, 0.7)
const COLOR_EJE_V := Color(1.0, 0.65, 0.3, 0.7)
const GROSOR_EJE := 2.0
const LARGO_GUION := 14.0
const EXTENSION_EJE := 2500.0
const INTERVALO_SYNC := 0.1
const TOLERANCIA_POSICION := 1.0
const TOLERANCIA_ANGULO := 0.02
const TOLERANCIA_ESCALA := 0.01
const META_EJES := "ejes_simetria"

var cargador : CargadorDeNivel
var espejo_horizontal : bool = false
var espejo_vertical : bool = false
var zona : Rect2
var pares : Array[Dictionary] = []
var tiempo_acumulado : float = 0.0


func _ready() -> void:
	z_index = 100


func configurar(horizontal : bool, vertical : bool) -> void:
	espejo_horizontal = horizontal
	espejo_vertical = vertical
	actualizar_zona()
	emparejar_existentes()
	queue_redraw()


func activa() -> bool:
	return espejo_horizontal or espejo_vertical


func relaciones_activas() -> Array[Vector2i]:
	var relaciones : Array[Vector2i] = []
	if espejo_horizontal:
		relaciones.append(Vector2i(1, 0))
	if espejo_vertical:
		relaciones.append(Vector2i(0, 1))
	if espejo_horizontal and espejo_vertical:
		relaciones.append(Vector2i(1, 1))
	return relaciones


func actualizar_zona() -> void:
	var estructura : EstructuraDeNivel = cargador.obtener_estructura() if cargador else null
	var divisiones : DivisionesPachinko
	var divisor : Node2D
	var fondo : float
	if not estructura:
		push_warning("No hay EstructuraDeNivel en la escena, la simetria usa la zona que habia")
		return
	zona = estructura.zona_jugable()
	fondo = zona.end.y
	divisiones = cargador.obtener_divisiones()
	if divisiones:
		fondo = divisiones.global_position.y
		if divisiones.get_child_count() > 0:
			divisor = divisiones.get_child(0)
			if "alto" in divisor and "radio_punta" in divisor:
				fondo -= divisor.alto + divisor.radio_punta
	zona.size.y = fondo - zona.position.y
	zona = Rect2(to_local(zona.position), zona.size)


func _draw() -> void:
	var centro : Vector2 = zona.get_center()
	if espejo_horizontal:
		draw_dashed_line(Vector2(centro.x, zona.position.y - EXTENSION_EJE), Vector2(centro.x, zona.end.y + EXTENSION_EJE), COLOR_EJE_H, GROSOR_EJE, LARGO_GUION)
	if espejo_vertical:
		draw_dashed_line(Vector2(zona.position.x - EXTENSION_EJE, centro.y), Vector2(zona.end.x + EXTENSION_EJE, centro.y), COLOR_EJE_V, GROSOR_EJE, LARGO_GUION)


func _process(delta : float) -> void:
	if not Engine.is_editor_hint() or not activa() or not cargador:
		return
	tiempo_acumulado += delta
	if tiempo_acumulado < INTERVALO_SYNC:
		return
	tiempo_acumulado = 0.0
	revisar_toggles()
	sincronizar_pares()


func raiz_de(forma : Node2D) -> Node2D:
	var actual : Node = forma
	while actual and actual.get_parent() != cargador:
		actual = actual.get_parent()
	return actual as Node2D


func registrar_nueva(forma : Node2D) -> Array[Node2D]:
	var copia : Node2D
	var tipo : String = forma.obtener_datos().tipo
	var raices : Array[Node2D] = []
	if "usar_simetria" in forma:
		forma.usar_simetria = true
		fijar_ejes(forma)
	for relacion in ejes_de(forma):
		copia = cargador.crear_forma(tipo, cargador)
		sincronizar(forma, copia, relacion)
		copia.usar_simetria = false
		asignar_grupo(forma, copia, relacion)
		pares.append(par_nuevo(forma, copia, relacion, true))
		raices.append(raiz_de(copia))
	return raices


func asignar_grupo(original : Node2D, copia : Node2D, relacion : Vector2i) -> void:
	var grupo : int = original.get_meta("grupo_simetria", 0)
	if grupo == 0:
		grupo = proximo_grupo()
		original.set_meta("grupo_simetria", grupo)
		original.set_meta("rol_simetria", Vector2i.ZERO)
	copia.set_meta("grupo_simetria", grupo)
	copia.set_meta("rol_simetria", relacion)


func proximo_grupo() -> int:
	var maximo : int = 0
	var forma : Node2D
	for raiz in cargador.obtener_raices_de_formas():
		forma = forma_de(raiz)
		if forma:
			maximo = maxi(maximo, forma.get_meta("grupo_simetria", 0))
	return maximo + 1


func par_nuevo(a : Node2D, b : Node2D, relacion : Vector2i, clon : bool = false) -> Dictionary:
	return {"a": a, "b": b, "rel": relacion, "clon": clon, "huella_a": huella(a), "huella_b": huella(b)}


func emparejar_existentes() -> void:
	var formas : Array[Node2D] = []
	var usadas : Dictionary = {}
	pares.clear()
	for raiz in cargador.obtener_raices_de_formas():
		formas.append(forma_de(raiz))
	emparejar_por_grupo(formas)
	for relacion in relaciones_activas():
		usadas.clear()
		for i in formas.size():
			if usadas.has(formas[i]) or tiene_par(formas[i], relacion):
				continue
			for j in range(i + 1, formas.size()):
				if usadas.has(formas[j]) or tiene_par(formas[j], relacion):
					continue
				if not admite(formas[i], relacion) and not admite(formas[j], relacion):
					continue
				if es_espejo(formas[i], formas[j], relacion):
					usadas[formas[i]] = true
					usadas[formas[j]] = true
					pares.append(par_nuevo(formas[i], formas[j], relacion))
					break


func emparejar_por_grupo(formas : Array[Node2D]) -> void:
	var grupos : Dictionary = {}
	var original : Node2D
	var rol : Vector2i
	for forma in formas:
		if forma and forma.get_meta("grupo_simetria", 0) != 0:
			grupos.get_or_add(forma.get_meta("grupo_simetria"), []).append(forma)
	for grupo in grupos.values():
		original = null
		for miembro in grupo:
			if miembro.get_meta("rol_simetria", Vector2i.ZERO) == Vector2i.ZERO:
				original = miembro
				break
		if not original:
			continue
		for miembro in grupo:
			rol = miembro.get_meta("rol_simetria", Vector2i.ZERO)
			if miembro == original or rol == Vector2i.ZERO:
				continue
			if tiene_par(original, rol):
				continue
			if not admite(original, rol) and not admite(miembro, rol):
				continue
			if not es_espejo(original, miembro, rol):
				sincronizar(original, miembro, rol)
			pares.append(par_nuevo(original, miembro, rol, true))


func forma_de(raiz : Node2D) -> Node2D:
	if raiz is MovimientoPorPath:
		return raiz.obtener_forma()
	return raiz


func revisar_toggles() -> void:
	var forma : Node2D
	var copia : Node2D
	for raiz in cargador.obtener_raices_de_formas():
		forma = forma_de(raiz)
		if not forma or not "usar_simetria" in forma:
			continue
		if not forma.usar_simetria:
			if forma.has_meta(META_EJES):
				forma.remove_meta(META_EJES)
			continue
		if not forma.has_meta(META_EJES):
			inferir_ejes(forma)
		for relacion in ejes_de(forma):
			if tiene_par(forma, relacion):
				continue
			copia = buscar_espejo_existente(forma, relacion)
			if copia:
				pares.append(par_nuevo(forma, copia, relacion))
				continue
			copia = cargador.crear_forma(forma.obtener_datos().tipo, cargador)
			sincronizar(forma, copia, relacion)
			copia.usar_simetria = false
			asignar_grupo(forma, copia, relacion)
			pares.append(par_nuevo(forma, copia, relacion, true))


func buscar_espejo_existente(forma : Node2D, relacion : Vector2i) -> Node2D:
	var otra : Node2D
	for raiz in cargador.obtener_raices_de_formas():
		otra = forma_de(raiz)
		if not otra or otra == forma or tiene_par(otra, relacion):
			continue
		if es_espejo(forma, otra, relacion):
			return otra
	return null


func con_toggle(forma : Node2D) -> bool:
	return "usar_simetria" in forma and forma.usar_simetria


func fijar_ejes(forma : Node2D) -> void:
	forma.set_meta(META_EJES, relaciones_activas())


func inferir_ejes(forma : Node2D) -> void:
	var ejes : Array[Vector2i] = []
	var grupo : int = forma.get_meta("grupo_simetria", 0)
	var otra : Node2D
	var rol : Vector2i
	if grupo != 0:
		for raiz in cargador.obtener_raices_de_formas():
			otra = forma_de(raiz)
			if not otra or otra == forma or otra.get_meta("grupo_simetria", 0) != grupo:
				continue
			rol = otra.get_meta("rol_simetria", Vector2i.ZERO)
			if rol != Vector2i.ZERO and not ejes.has(rol):
				ejes.append(rol)
	if ejes.is_empty():
		fijar_ejes(forma)
	else:
		forma.set_meta(META_EJES, ejes)


func ejes_de(forma : Node2D) -> Array[Vector2i]:
	var ejes : Array[Vector2i] = []
	if forma and forma.has_meta(META_EJES):
		ejes.assign(forma.get_meta(META_EJES))
	return ejes


func admite(forma : Node2D, relacion : Vector2i) -> bool:
	return con_toggle(forma) and ejes_de(forma).has(relacion)


func tiene_par(forma : Node2D, relacion : Vector2i) -> bool:
	for par in pares:
		if par.rel == relacion and (par.a == forma or par.b == forma):
			return true
	return false


func sincronizar_pares() -> void:
	var vigentes : Array[Dictionary] = []
	var seleccionados : Array[Node] = []
	if Engine.is_editor_hint():
		seleccionados = EditorInterface.get_selection().get_selected_nodes()
	var ha : String
	var hb : String
	var fuente_a : bool
	for par in pares:
		if not is_instance_valid(par.a) or not is_instance_valid(par.b):
			borrar_sobreviviente(par)
			continue
		if not raiz_de(par.a) or not raiz_de(par.b):
			continue
		if not con_toggle(par.a) and not con_toggle(par.b):
			if par.get("clon", false):
				borrar_raiz(par.b)
			continue
		vigentes.append(par)
		ha = huella(par.a)
		hb = huella(par.b)
		if ha == par.huella_a and hb == par.huella_b:
			continue
		if ha != par.huella_a and hb != par.huella_b:
			fuente_a = esta_seleccionada(par.a, seleccionados) or not esta_seleccionada(par.b, seleccionados)
		else:
			fuente_a = ha != par.huella_a
		if fuente_a:
			sincronizar(par.a, par.b, par.rel)
		else:
			sincronizar(par.b, par.a, par.rel)
		par.huella_a = huella(par.a)
		par.huella_b = huella(par.b)
	pares = vigentes


func borrar_sobreviviente(par : Dictionary) -> void:
	borrar_raiz(par.a if is_instance_valid(par.a) else par.b)


func borrar_raiz(forma : Node2D) -> void:
	var raiz : Node2D
	if not is_instance_valid(forma):
		return
	raiz = raiz_de(forma)
	if raiz and is_instance_valid(raiz):
		raiz.queue_free()


func esta_seleccionada(forma : Node2D, seleccionados : Array[Node]) -> bool:
	var raiz : Node2D = raiz_de(forma)
	for nodo in seleccionados:
		if nodo == forma or nodo == raiz or raiz.is_ancestor_of(nodo):
			return true
	return false


func sincronizar(fuente : Node2D, copia : Node2D, relacion : Vector2i) -> void:
	var raiz_fuente : Node2D = raiz_de(fuente)
	var raiz_copia : Node2D = raiz_de(copia)
	var datos : FormaData = raiz_fuente.obtener_datos()
	var toggle_copia : bool = con_toggle(copia)
	var grupo_copia : int = copia.get_meta("grupo_simetria", 0)
	var rol_copia : Vector2i = copia.get_meta("rol_simetria", Vector2i.ZERO)
	var ejes_copia : Array[Vector2i] = ejes_de(copia)
	if raiz_fuente is MovimientoPorPath and not raiz_copia is MovimientoPorPath:
		raiz_copia = cargador.agregar_recorrido(copia, cargador)
	elif not raiz_fuente is MovimientoPorPath and raiz_copia is MovimientoPorPath:
		cargador.quitar_recorrido(raiz_copia, cargador)
		raiz_copia = copia
		copia.owner = cargador
	copia.aplicar_datos(datos)
	if "usar_simetria" in copia:
		copia.usar_simetria = toggle_copia
	if ejes_copia.is_empty():
		if copia.has_meta(META_EJES):
			copia.remove_meta(META_EJES)
	else:
		copia.set_meta(META_EJES, ejes_copia)
	if grupo_copia != 0:
		copia.set_meta("grupo_simetria", grupo_copia)
		copia.set_meta("rol_simetria", rol_copia)
	elif copia.has_meta("grupo_simetria"):
		copia.remove_meta("grupo_simetria")
		copia.remove_meta("rol_simetria")
	if raiz_copia is MovimientoPorPath:
		var arranque_copia : bool = raiz_copia.arranque_invertido
		raiz_copia.aplicar_datos(datos)
		raiz_copia.arranque_invertido = arranque_copia
		copia.position = fuente.position
		copia.rotation = fuente.rotation
		copia.scale = fuente.scale
	aplicar_transform_espejada(raiz_fuente, raiz_copia, relacion)


func aplicar_transform_espejada(raiz_fuente : Node2D, raiz_copia : Node2D, relacion : Vector2i) -> void:
	raiz_copia.position = reflejar(raiz_fuente.position, relacion)
	if relacion == Vector2i(1, 1):
		raiz_copia.rotation = wrapf(raiz_fuente.rotation + PI, -PI, PI)
		raiz_copia.scale = raiz_fuente.scale
	else:
		raiz_copia.rotation = -raiz_fuente.rotation
		raiz_copia.scale = Vector2(
			raiz_fuente.scale.x * (-1.0 if relacion.x == 1 else 1.0),
			raiz_fuente.scale.y * (-1.0 if relacion.y == 1 else 1.0)
		)


func reflejar(punto : Vector2, relacion : Vector2i) -> Vector2:
	var centro : Vector2 = zona.get_center()
	var reflejado : Vector2 = punto
	if relacion.x == 1:
		reflejado.x = 2.0 * centro.x - punto.x
	if relacion.y == 1:
		reflejado.y = 2.0 * centro.y - punto.y
	return reflejado


func es_espejo(a : Node2D, b : Node2D, relacion : Vector2i) -> bool:
	var raiz_a : Node2D = raiz_de(a)
	var raiz_b : Node2D = raiz_de(b)
	var esperada_posicion : Vector2
	var esperada_rotacion : float
	var esperada_escala : Vector2
	if raiz_a.get_script() != raiz_b.get_script():
		return false
	if huella_contenido(a) != huella_contenido(b):
		return false
	esperada_posicion = reflejar(raiz_a.position, relacion)
	if relacion == Vector2i(1, 1):
		esperada_rotacion = wrapf(raiz_a.rotation + PI, -PI, PI)
		esperada_escala = raiz_a.scale
	else:
		esperada_rotacion = -raiz_a.rotation
		esperada_escala = Vector2(
			raiz_a.scale.x * (-1.0 if relacion.x == 1 else 1.0),
			raiz_a.scale.y * (-1.0 if relacion.y == 1 else 1.0)
		)
	if esperada_posicion.distance_to(raiz_b.position) > TOLERANCIA_POSICION:
		return false
	if absf(wrapf(esperada_rotacion - raiz_b.rotation, -PI, PI)) > TOLERANCIA_ANGULO:
		return false
	if not esperada_escala.is_equal_approx(raiz_b.scale) and esperada_escala.distance_to(raiz_b.scale) > TOLERANCIA_ESCALA:
		return false
	return true


func huella(forma : Node2D) -> String:
	var raiz : Node2D = raiz_de(forma)
	if not raiz:
		return ""
	return "%s|%v|%f|%v|%s" % [raiz.get_script().resource_path, raiz.position, raiz.rotation, raiz.scale, huella_contenido(forma)]


func huella_contenido(forma : Node2D) -> String:
	var raiz : Node2D = raiz_de(forma)
	var partes : Array = []
	if forma is FormaSpawn:
		partes.append_array([forma.separacion_ovillos, forma.anillos_interiores, forma.anillos_exteriores, forma.separacion_anillos, forma.velocidad_desplazamiento, forma.invertir_desplazamiento, forma.alternar_direccion_anillos])
	if "tamaño" in forma:
		partes.append(forma.tamaño)
	if "radio" in forma:
		partes.append(forma.radio)
	if "huecos" in forma:
		partes.append(forma.huecos)
	if forma is FormaLinea:
		partes.append_array([forma.largo, forma.repeticiones, forma.separacion_repeticiones, forma.eje_repeticiones, forma.offset_repeticiones, forma.efecto_ladrillo, forma.velocidad_desplazamiento, forma.invertir_desplazamiento, forma.alternar_direccion_repeticiones])
	if forma is FormaPoligono:
		partes.append_array([forma.polygon, forma.separacion_ovillos, forma.angulo_grilla, forma.separacion_filas, forma.offset_grilla, forma.efecto_ladrillo, forma.velocidad_desplazamiento, forma.invertir_desplazamiento, forma.alternar_direccion_filas])
	if forma is FormaPath:
		partes.append_array([forma.separacion_ovillos, forma.repeticiones, forma.separacion_repeticiones, forma.eje_repeticiones, forma.offset_repeticiones, forma.velocidad_desplazamiento, forma.invertir_desplazamiento, forma.alternar_direccion_repeticiones, forma.efecto_ladrillo, texto_curva(forma.curve)])
	if raiz is MovimientoPorPath:
		partes.append_array([texto_curva(raiz.curve), raiz.velocidad, raiz.bucle, raiz.ida_y_vuelta, raiz.rotar_con_el_path, raiz.progreso_inicial, raiz.invertido, raiz.copias_recorrido, forma.position, forma.rotation, forma.scale])
	return var_to_str(partes)


func texto_curva(curva : Curve2D) -> String:
	var partes : Array = []
	if not curva:
		return ""
	for i in curva.point_count:
		partes.append_array([curva.get_point_position(i), curva.get_point_in(i), curva.get_point_out(i)])
	return var_to_str(partes)
