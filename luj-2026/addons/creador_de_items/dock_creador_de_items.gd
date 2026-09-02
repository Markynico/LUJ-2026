@tool
class_name DockCreadorDeItems
extends ScrollContainer

const TIPOS : Dictionary = {
	"Reliquia": {
		"base_hooks": "res://scripts/reliquias/efecto_reliquia.gd",
		"clase_base": "Reliquia",
		"carpeta_scripts": "res://scripts/reliquias/",
		"prefijo_script": "reliquia_",
		"carpeta_resources": "res://scripts/resources/reliquias/",
	},
	"Comida": {
		"base_hooks": "res://scripts/pelotitas_custom/efectos_pelotita.gd",
		"clase_base": "EfectosPelotita",
		"carpeta_scripts": "res://scripts/pelotitas_custom/",
		"prefijo_script": "efecto_",
		"carpeta_resources": "res://scripts/resources/comidas/",
	},
}
const NO_SON_HOOKS : Array[String] = ["rebote_simple", "descripcion_para_mostrar", "fuentes"]
const ACENTOS : Dictionary = {"á": "a", "é": "e", "í": "i", "ó": "o", "ú": "u", "ü": "u", "ñ": "n"}

@export var selector_tipo : OptionButton
@export var campo_nombre : LineEdit
@export var selector_rareza : OptionButton
@export var campo_descripcion : TextEdit
@export var selector_icono : EditorResourcePicker
@export var fila_textura : Control
@export var selector_textura : EditorResourcePicker
@export var contenedor_hooks : VBoxContainer
@export var boton_crear : Button
@export var etiqueta_estado : Label

var casillas : Array[CheckBox] = []
var hooks : Array[Dictionary] = []


func _ready() -> void:
	selector_tipo.clear()
	for tipo in TIPOS:
		selector_tipo.add_item(tipo)
	selector_rareza.clear()
	for nombre in Rareza.NOMBRES:
		selector_rareza.add_item(nombre)
	selector_tipo.item_selected.connect(al_cambiar_tipo)
	boton_crear.pressed.connect(crear)
	visibility_changed.connect(armar_hooks)
	al_cambiar_tipo(0)


func tipo_actual() -> String:
	return selector_tipo.get_item_text(selector_tipo.selected)


func datos_tipo() -> Dictionary:
	return TIPOS[tipo_actual()]


func al_cambiar_tipo(indice : int) -> void:
	fila_textura.visible = tipo_actual() == "Comida"
	armar_hooks()


func armar_hooks() -> void:
	var base : Script = load(datos_tipo()["base_hooks"])
	var marcados : Array[String] = hooks_marcados()
	var casilla : CheckBox
	for hijo in contenedor_hooks.get_children():
		hijo.queue_free()
	casillas.clear()
	hooks.clear()
	if not base:
		return
	for metodo in base.get_script_method_list():
		if metodo["name"] in NO_SON_HOOKS or metodo["name"].begins_with("_"):
			continue
		hooks.append(metodo)
		casilla = CheckBox.new()
		casilla.text = metodo["name"]
		casilla.tooltip_text = firma(metodo)
		casilla.button_pressed = metodo["name"] in marcados
		contenedor_hooks.add_child(casilla)
		casillas.append(casilla)


func hooks_marcados() -> Array[String]:
	var resultado : Array[String] = []
	for casilla in casillas:
		if is_instance_valid(casilla) and casilla.button_pressed:
			resultado.append(casilla.text)
	return resultado


func firma(metodo : Dictionary) -> String:
	var argumentos : PackedStringArray = []
	var retorno : String = tipo_a_texto(metodo["return"])
	for argumento in metodo["args"]:
		argumentos.append("%s : %s" % [argumento["name"], tipo_a_texto(argumento)])
	if retorno.is_empty():
		return "func %s(%s):" % [metodo["name"], ", ".join(argumentos)]
	return "func %s(%s) -> %s:" % [metodo["name"], ", ".join(argumentos), retorno]


func tipo_a_texto(info : Dictionary) -> String:
	if info["type"] == TYPE_OBJECT:
		return info["class_name"]
	if info["type"] == TYPE_NIL:
		if info["usage"] & PROPERTY_USAGE_NIL_IS_VARIANT:
			return ""
		return "void"
	return type_string(info["type"])


func cuerpo(metodo : Dictionary) -> String:
	var nombres : PackedStringArray = []
	var retorno : String = tipo_a_texto(metodo["return"])
	for argumento in metodo["args"]:
		nombres.append(argumento["name"])
	if retorno == "void":
		return "\tpass"
	if retorno.is_empty():
		return "\tsuper(%s)" % ", ".join(nombres)
	return "\treturn super(%s)" % ", ".join(nombres)


func generar_script(clase : String, base : String) -> String:
	var texto : String = "class_name %s\nextends %s\n" % [clase, base]
	var marcados : Array[String] = hooks_marcados()
	for metodo in hooks:
		if metodo["name"] in marcados:
			texto += "\n\n%s\n%s\n" % [firma(metodo), cuerpo(metodo)]
	return texto


func slug(nombre : String) -> String:
	var resultado : String = nombre.to_lower()
	var limpio : String = ""
	for acento in ACENTOS:
		resultado = resultado.replace(acento, ACENTOS[acento])
	for caracter in resultado:
		if caracter.is_valid_identifier() or caracter.is_valid_int():
			limpio += caracter
		elif not limpio.ends_with("_") and not limpio.is_empty():
			limpio += "_"
	return limpio.trim_suffix("_")


func pascal(nombre : String) -> String:
	var resultado : String = ""
	for parte in slug(nombre).split("_", false):
		resultado += parte.capitalize()
	return resultado


func avisar(texto : String) -> void:
	etiqueta_estado.text = texto


func crear() -> void:
	var nombre : String = campo_nombre.text.strip_edges()
	var datos : Dictionary = datos_tipo()
	var ruta_script : String = datos["carpeta_scripts"] + datos["prefijo_script"] + slug(nombre) + ".gd"
	var clase : String = datos["prefijo_script"].capitalize().replace(" ", "") + pascal(nombre)
	var script : Script = load(datos["base_hooks"]) if tipo_actual() == "Comida" else load("res://scripts/reliquias/reliquia.gd")
	var ruta_resource : String = datos["carpeta_resources"] + slug(nombre) + ".tres"
	if nombre.is_empty():
		avisar("Falta el nombre")
		return
	if FileAccess.file_exists(ruta_resource) or FileAccess.file_exists(ruta_script):
		avisar("Ya existe un item con ese nombre")
		return
	if ClassDB.class_exists(clase) or not ProjectSettings.get_global_class_list().filter(func(info : Dictionary) -> bool: return info["class"] == clase).is_empty():
		avisar("Ya existe la clase " + clase)
		return
	DirAccess.make_dir_recursive_absolute(datos["carpeta_resources"])
	if not hooks_marcados().is_empty():
		script = escribir_script(ruta_script, generar_script(clase, datos["clase_base"]))
		if not script:
			avisar("No se pudo escribir " + ruta_script)
			return
	if tipo_actual() == "Comida":
		crear_comida(nombre, script, ruta_resource)
	else:
		crear_reliquia(nombre, script, ruta_resource)
	if script.resource_path == ruta_script:
		EditorInterface.edit_script(script)
	campo_nombre.text = ""
	avisar("Creado " + ruta_resource)


func escribir_script(ruta : String, contenido : String) -> Script:
	var archivo : FileAccess = FileAccess.open(ruta, FileAccess.WRITE)
	if not archivo:
		return null
	archivo.store_string(contenido)
	archivo.close()
	EditorInterface.get_resource_filesystem().update_file(ruta)
	return load(ruta)


func guardar(recurso : Resource, ruta : String) -> Resource:
	ResourceSaver.save(recurso, ruta)
	EditorInterface.get_resource_filesystem().update_file(ruta)
	return load(ruta)


func crear_reliquia(nombre : String, script : Script, ruta : String) -> void:
	var reliquia : Resource = script.new()
	reliquia.nombre = nombre
	reliquia.rareza = selector_rareza.selected
	reliquia.descripcion = campo_descripcion.text
	reliquia.icono = selector_icono.edited_resource
	EditorInterface.edit_resource(guardar(reliquia, ruta))


func crear_comida(nombre : String, script_efecto : Script, ruta : String) -> void:
	var efecto : Resource = script_efecto.new()
	var comida : Resource = load("res://scripts/pelotitas_custom/pelotita_base.gd").new()
	var ruta_efecto : String = ruta.get_base_dir().path_join("efecto_" + ruta.get_file())
	efecto.nombre_comida = nombre
	efecto = guardar(efecto, ruta_efecto)
	comida.nombre = nombre
	comida.rareza = selector_rareza.selected
	comida.descripcion = campo_descripcion.text
	comida.imagen_comida_asociada = selector_icono.edited_resource
	comida.textura = selector_textura.edited_resource
	comida.efectos = [efecto]
	EditorInterface.edit_resource(guardar(comida, ruta))
