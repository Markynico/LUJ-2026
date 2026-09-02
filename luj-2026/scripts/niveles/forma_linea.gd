@tool
class_name FormaLinea
extends FormaSpawn

enum Manija { CENTRO, ROTACION, EXTREMO_A, EXTREMO_B }

const COLOR_REPETICION := Color(0.3, 0.9, 1.0, 0.5)

##largo de la linea, centrada en la posicion del nodo
@export var largo : float = 200.0:
	set(valor):
		largo = maxf(valor, 1.0)
		actualizar()

@export_group("Repeticiones")
##copias de la linea a cada lado de la original
@export_range(0, 20, 1) var repeticiones : int = 0:
	set(valor):
		repeticiones = maxi(valor, 0)
		actualizar()
##distancia entre una copia y la siguiente
@export var separacion_repeticiones : int = 80:
	set(valor):
		separacion_repeticiones = maxi(valor, 1)
		actualizar()
##eje local de la linea sobre el que se desplazan las copias, horizontal es a lo largo de la linea
@export_enum("Horizontal", "Vertical") var eje_repeticiones : int = 1:
	set(valor):
		eje_repeticiones = valor
		actualizar()
##desplazamiento extra que se acumula en cada copia, ademas del eje
@export var offset_repeticiones : Vector2 = Vector2.ZERO:
	set(valor):
		offset_repeticiones = valor
		actualizar()
##las copias alternadas corren sus ovillos medio paso, como ladrillos
@export var efecto_ladrillo : bool = false:
	set(valor):
		efecto_ladrillo = valor
		actualizar()

@export_group("Desplazamiento")
##las repeticiones alternan el sentido del desplazamiento entre si
@export var alternar_direccion_repeticiones : bool = false


func _draw() -> void:
	var trazo : PackedVector2Array
	if not Engine.is_editor_hint():
		return
	super()
	trazo = obtener_contorno()
	for desplazamiento in desplazamientos_de_repeticiones():
		draw_line(trazo[0] + desplazamiento, trazo[1] + desplazamiento, COLOR_DIBUJO if desplazamiento == Vector2.ZERO else COLOR_REPETICION, GROSOR_DIBUJO)


func obtener_contorno() -> PackedVector2Array:
	return PackedVector2Array([Vector2(-largo * 0.5, 0.0), Vector2(largo * 0.5, 0.0)])


func contorno_cerrado() -> bool:
	return false


func permite_anillos() -> bool:
	return false


func _validate_property(propiedad : Dictionary) -> void:
	if propiedad.name in ["anillos_interiores", "anillos_exteriores", "separacion_anillos", "alternar_direccion_anillos"]:
		propiedad.usage = PROPERTY_USAGE_NO_EDITOR


func obtener_radio_exterior() -> float:
	return largo * 0.5


func desplazamientos_de_repeticiones() -> Array[Vector2]:
	var lista : Array[Vector2] = [Vector2.ZERO]
	var direccion : Vector2 = Vector2.RIGHT if eje_repeticiones == 0 else Vector2.DOWN
	var paso : Vector2 = direccion * float(separacion_repeticiones) + offset_repeticiones
	for i in range(1, repeticiones + 1):
		lista.append(paso * float(i))
		lista.append(paso * float(-i))
	return lista


func obtener_puntos() -> PackedVector2Array:
	var base : PackedVector2Array = obtener_contorno()
	var resultado : PackedVector2Array = PackedVector2Array()
	var desplazamientos : Array[Vector2] = desplazamientos_de_repeticiones()
	var fase : float
	var paso : int
	var trazo : PackedVector2Array
	for indice in desplazamientos.size():
		paso = (indice + 1) / 2
		fase = fase_desplazamiento
		if alternar_direccion_repeticiones and paso % 2 == 1:
			fase = -fase
		trazo = PackedVector2Array([base[0] + desplazamientos[indice], base[1] + desplazamientos[indice]])
		resultado.append_array(puntos_sobre_linea(a_global(trazo), fase, efecto_ladrillo and paso % 2 == 1))
	return resultado


func puntos_sobre_linea(trazo : PackedVector2Array, fase : float, medio_paso : bool) -> PackedVector2Array:
	var resultado : PackedVector2Array = PackedVector2Array()
	var largo_real : float = trazo[0].distance_to(trazo[1])
	var cantidad : int = calcular_cantidad_ovillos(largo_real)
	var total : int
	if cantidad == 0 or largo_real <= 0.0:
		return resultado
	if medio_paso:
		fase += largo_real / cantidad * 0.5
	total = cantidad + 1 if velocidad_desplazamiento == 0.0 and not medio_paso else cantidad
	for i in total:
		resultado.append(trazo[0].lerp(trazo[1], fposmod(largo_real * i / cantidad + fase, largo_real) / largo_real))
	return resultado


func obtener_manijas() -> PackedVector2Array:
	var manijas : PackedVector2Array = super()
	manijas.append_array(obtener_contorno())
	return manijas


func mover_manija(indice : int, posicion_local : Vector2, con_shift : bool, con_control : bool) -> void:
	var contorno : PackedVector2Array
	var fijo_global : Vector2
	var nuevo_global : Vector2
	var direccion : Vector2
	if indice < Manija.EXTREMO_A:
		super(indice, posicion_local, con_shift, con_control)
		return
	contorno = obtener_contorno()
	fijo_global = to_global(contorno[1] if indice == Manija.EXTREMO_A else contorno[0])
	nuevo_global = to_global(posicion_local)
	direccion = fijo_global - nuevo_global if indice == Manija.EXTREMO_A else nuevo_global - fijo_global
	if con_shift:
		direccion = Vector2.from_angle(snappedf(direccion.angle(), PASO_SNAP_ROTACION)) * direccion.length()
		nuevo_global = fijo_global - direccion if indice == Manija.EXTREMO_A else fijo_global + direccion
	global_position = (fijo_global + nuevo_global) * 0.5
	global_rotation = direccion.angle()
	largo = direccion.length() / maxf(absf(scale.x), 0.001)


func obtener_datos() -> FormaData:
	var datos : FormaData = super()
	datos.tipo = "linea"
	datos.largo = largo
	datos.repeticiones = repeticiones
	datos.separacion_repeticiones = separacion_repeticiones
	datos.eje_repeticiones = eje_repeticiones
	datos.offset_repeticiones = offset_repeticiones
	datos.efecto_ladrillo = efecto_ladrillo
	datos.alternar_direccion_repeticiones = alternar_direccion_repeticiones
	return datos


func aplicar_datos(datos : FormaData) -> void:
	super(datos)
	largo = datos.largo
	repeticiones = datos.repeticiones
	separacion_repeticiones = datos.separacion_repeticiones
	eje_repeticiones = datos.eje_repeticiones
	offset_repeticiones = datos.offset_repeticiones
	efecto_ladrillo = datos.efecto_ladrillo
	alternar_direccion_repeticiones = datos.alternar_direccion_repeticiones
