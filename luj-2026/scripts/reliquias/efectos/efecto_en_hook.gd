@tool
class_name EfectoEnHook
extends EfectoReliquia

##hook de la reliquia en el que se disparan las acciones
var hook : String = "al_obtener"
##cada cuantas veces que ocurre el hook se disparan las acciones, 1 = siempre
@export var cada : int = 1
##probabilidad en porcentaje de que las acciones se ejecuten cuando toca
@export_range(0.0, 100.0) var probabilidad : float = 100.0
##veces maximas que se ejecutan las acciones en la run, 0 = sin limite
@export var usos_maximos : int = 0
##acciones que se ejecutan cuando ocurre el hook
@export var acciones : Array[AccionReliquia] = []
##acciones que se ejecutan si la probabilidad falla
@export var acciones_si_falla : Array[AccionReliquia] = []

var veces : int = 0
var usos : int = 0


func _get_property_list() -> Array[Dictionary]:
	return [{
		"name": "hook",
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": ",".join(hooks_disponibles()),
		"usage": PROPERTY_USAGE_DEFAULT,
	}]


static func hooks_disponibles() -> PackedStringArray:
	var resultado : PackedStringArray = []
	var base : Script = load("res://scripts/reliquias/efecto_reliquia.gd")
	for metodo in base.get_script_method_list():
		if metodo["name"] == "evento" or metodo["return"]["type"] != TYPE_NIL:
			continue
		resultado.append(metodo["name"])
	return resultado


func evento(nombre : String, contexto : Dictionary) -> void:
	var ejecutadas : bool = false
	if nombre != hook:
		return
	if nombre == "al_obtener":
		veces = 0
		usos = 0
	if usos_maximos > 0 and usos >= usos_maximos:
		return
	veces += 1
	if cada > 1 and veces % cada != 0:
		return
	if randf() * 100.0 <= probabilidad:
		for accion in acciones:
			if accion and accion.ejecutar(contexto):
				ejecutadas = true
	else:
		for accion in acciones_si_falla:
			if accion and accion.ejecutar(contexto):
				ejecutadas = true
	if ejecutadas:
		usos += 1
