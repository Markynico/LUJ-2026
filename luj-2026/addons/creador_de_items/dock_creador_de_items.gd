@tool
class_name DockCreadorDeItems
extends ScrollContainer

const TIPOS : Dictionary = {
	"Reliquia": {
		"script_base": "res://scripts/reliquias/reliquia.gd",
		"script_hooks": "res://scripts/reliquias/efecto_reliquia.gd",
		"script_contenedor": "res://scripts/reliquias/reliquia.gd",
		"clase_base": "Reliquia",
		"clase_contenedor": "Reliquia",
		"propiedad_efectos": "",
		"propiedad_icono": "icono",
		"nombre_en_efecto": "",
		"con_rareza": true,
		"con_textura": false,
		"etiqueta_icono": "Icono",
		"carpeta_scripts": "res://scripts/reliquias/",
		"prefijo_script": "reliquia_",
		"carpeta_resources": "res://scripts/resources/reliquias/",
		"carpetas_existentes": ["res://scripts/resources/reliquias/"],
	},
	"Comida": {
		"script_base": "res://scripts/pelotitas_custom/efectos_pelotita.gd",
		"script_hooks": "res://scripts/pelotitas_custom/efectos_pelotita.gd",
		"script_contenedor": "res://scripts/pelotitas_custom/pelotita_base.gd",
		"clase_base": "EfectosPelotita",
		"clase_contenedor": "PelotitaBase",
		"propiedad_efectos": "efectos",
		"propiedad_icono": "imagen_comida_asociada",
		"nombre_en_efecto": "nombre_comida",
		"con_rareza": true,
		"con_textura": true,
		"etiqueta_icono": "Sprite comida",
		"carpeta_scripts": "res://scripts/pelotitas_custom/",
		"prefijo_script": "efecto_",
		"carpeta_resources": "res://scripts/resources/comidas/",
		"carpetas_existentes": ["res://scripts/resources/comidas/", "res://scripts/resources/"],
	},
	"Ovillo": {
		"script_base": "res://scripts/ovillos_custom/efecto_ovillo_base.gd",
		"script_hooks": "res://scripts/ovillos_custom/efecto_ovillo_base.gd",
		"script_contenedor": "res://scripts/ovillos_custom/ovillo_base.gd",
		"clase_base": "EfectosOvillo",
		"clase_contenedor": "OvilloBase",
		"propiedad_efectos": "efectos_al_recibir_impacto",
		"propiedad_icono": "sprite",
		"nombre_en_efecto": "",
		"con_rareza": false,
		"con_textura": false,
		"etiqueta_icono": "Sprite",
		"carpeta_scripts": "res://scripts/ovillos_custom/",
		"prefijo_script": "efecto_ovillo_",
		"carpeta_resources": "res://scripts/resources/ovillos/",
		"carpetas_existentes": ["res://scripts/resources/ovillos/", "res://scripts/resources/"],
	},
	"Estado de ovillo": {
		"script_base": "res://scripts/ovillos_custom/estados/estado_ovillo.gd",
		"script_hooks": "res://scripts/ovillos_custom/estados/efecto_estado_ovillo.gd",
		"script_contenedor": "res://scripts/ovillos_custom/estados/estado_ovillo.gd",
		"clase_base": "EstadoOvillo",
		"clase_contenedor": "EstadoOvillo",
		"propiedad_efectos": "",
		"propiedad_icono": "decoracion",
		"nombre_en_efecto": "",
		"con_rareza": false,
		"con_textura": false,
		"etiqueta_icono": "Decoracion",
		"carpeta_scripts": "res://scripts/ovillos_custom/estados/",
		"prefijo_script": "estado_",
		"carpeta_resources": "res://scripts/resources/estados/",
		"carpetas_existentes": ["res://scripts/resources/estados/"],
	},
}
const NO_SON_HOOKS : Array[String] = ["rebote_simple", "descripcion_para_mostrar", "fuentes", "iniciar", "gastar_carga", "pasar_turno"]
const ACENTOS : Dictionary = {"á": "a", "é": "e", "í": "i", "ó": "o", "ú": "u", "ü": "u", "ñ": "n"}

@export var selector_tipo : OptionButton
@export var selector_existente : OptionButton
@export var campo_nombre : LineEdit
@export var selector_rareza : OptionButton
@export var campo_descripcion : TextEdit
@export var etiqueta_icono : Label
@export var selector_icono : EditorResourcePicker
@export var fila_textura : Control
@export var selector_textura : EditorResourcePicker
@export var contenedor_hooks : VBoxContainer
@export var boton_crear : Button
@export var etiqueta_estado : Label

var casillas : Array[CheckBox] = []
var hooks : Array[Dictionary] = []
var existentes : Array[Resource] = []
var editando : Resource


func _ready() -> void:
	selector_tipo.clear()
	for tipo in TIPOS:
		selector_tipo.add_item(tipo)
	selector_rareza.clear()
	for nombre in Rareza.NOMBRES:
		selector_rareza.add_item(nombre)
	selector_tipo.item_selected.connect(al_cambiar_tipo)
	selector_existente.item_selected.connect(al_elegir_existente)
	boton_crear.pressed.connect(crear_o_guardar)
	visibility_changed.connect(al_cambiar_visibilidad)
	al_cambiar_tipo(0)


func tipo_actual() -> String:
	return selector_tipo.get_item_text(selector_tipo.selected)


func datos_tipo() -> Dictionary:
	return TIPOS[tipo_actual()]


func tiene_efectos() -> bool:
	return not datos_tipo()["propiedad_efectos"].is_empty()


func es_del_tipo(recurso : Resource) -> bool:
	var script : Script = recurso.get_script() if recurso else null
	var contenedor : Script = load(datos_tipo()["script_contenedor"])
	while script:
		if script == contenedor:
			return true
		script = script.get_base_script()
	return false


func al_cambiar_visibilidad() -> void:
	if visible:
		armar_hooks(hooks_marcados())
		armar_existentes()


func al_cambiar_tipo(indice : int) -> void:
	fila_textura.visible = datos_tipo()["con_textura"]
	selector_rareza.visible = datos_tipo()["con_rareza"]
	etiqueta_icono.text = datos_tipo()["etiqueta_icono"]
	editando = null
	armar_hooks([])
	armar_existentes()
	limpiar_campos()


func armar_existentes() -> void:
	var elegido : Resource = editando
	var directorio : DirAccess
	var nombre : String
	var recurso : Resource
	existentes.clear()
	for carpeta in datos_tipo()["carpetas_existentes"]:
		directorio = DirAccess.open(carpeta)
		if not directorio:
			continue
		directorio.list_dir_begin()
		nombre = directorio.get_next()
		while not nombre.is_empty():
			if nombre.ends_with(".tres") and not directorio.current_is_dir():
				recurso = load(carpeta.path_join(nombre))
				if es_del_tipo(recurso):
					existentes.append(recurso)
			nombre = directorio.get_next()
		directorio.list_dir_end()
	existentes.sort_custom(func(a : Resource, b : Resource) -> bool: return a.resource_path.get_file() < b.resource_path.get_file())
	selector_existente.clear()
	selector_existente.add_item("Nuevo...")
	for existente in existentes:
		selector_existente.add_item(existente.resource_path.get_file().get_basename())
	selector_existente.selected = existentes.find(elegido) + 1


func al_elegir_existente(indice : int) -> void:
	editando = existentes[indice - 1] if indice > 0 else null
	if editando:
		cargar_campos(editando)
		armar_hooks(hooks_del_script(script_editable(editando)))
	else:
		limpiar_campos()
		armar_hooks([])


func limpiar_campos() -> void:
	campo_nombre.text = ""
	campo_descripcion.text = ""
	selector_rareza.selected = 0
	selector_icono.edited_resource = null
	selector_textura.edited_resource = null
	boton_crear.text = "Crear"


func cargar_campos(recurso : Resource) -> void:
	campo_nombre.text = recurso.nombre
	campo_descripcion.text = recurso.descripcion
	if datos_tipo()["con_rareza"]:
		selector_rareza.selected = recurso.rareza
	selector_icono.edited_resource = recurso.get(datos_tipo()["propiedad_icono"])
	if datos_tipo()["con_textura"]:
		selector_textura.edited_resource = recurso.textura
	boton_crear.text = "Guardar"


func efecto_de(recurso : Resource) -> Resource:
	var efectos : Array
	if not recurso:
		return null
	if not tiene_efectos():
		return recurso
	efectos = recurso.get(datos_tipo()["propiedad_efectos"])
	if efectos == null or efectos.is_empty():
		return null
	return efectos[0]


func script_editable(recurso : Resource) -> Script:
	var efecto : Resource = efecto_de(recurso)
	return efecto.get_script() if efecto else null


func hooks_del_script(script : Script) -> Array[String]:
	var resultado : Array[String] = []
	if not script or script.resource_path == datos_tipo()["script_base"]:
		return resultado
	for metodo in script.get_script_method_list():
		resultado.append(metodo["name"])
	return resultado


func armar_hooks(marcados : Array[String]) -> void:
	var base : Script = load(datos_tipo()["script_hooks"])
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


func bloque_hook(metodo : Dictionary) -> String:
	return "\n\n%s\n%s\n" % [firma(metodo), cuerpo(metodo)]


func generar_script(clase : String, base : String) -> String:
	var texto : String = "class_name %s\nextends %s\n" % [clase, base]
	var marcados : Array[String] = hooks_marcados()
	for metodo in hooks:
		if metodo["name"] in marcados:
			texto += bloque_hook(metodo)
	return texto


func actualizar_script(script : Script) -> String:
	var texto : String = script.source_code
	var marcados : Array[String] = hooks_marcados()
	var existentes_en_script : Array[String] = hooks_del_script(script)
	var regex : RegEx = RegEx.new()
	var coincidencia : RegExMatch
	var conservados : Array[String] = []
	for metodo in hooks:
		if metodo["name"] in marcados and not metodo["name"] in existentes_en_script:
			texto = texto.trim_suffix("\n") + "\n" + bloque_hook(metodo)
		elif not metodo["name"] in marcados and metodo["name"] in existentes_en_script:
			regex.compile("\\n*func %s\\([^\\n]*\\n\\t(?:pass|return super\\([^\\n]*\\)|super\\([^\\n]*\\))\\n" % metodo["name"])
			coincidencia = regex.search(texto)
			if coincidencia:
				texto = texto.substr(0, coincidencia.get_start()) + "\n" + texto.substr(coincidencia.get_end())
			else:
				conservados.append(metodo["name"])
	if not conservados.is_empty():
		avisar("Se conservan porque tienen codigo propio: " + ", ".join(conservados))
	return texto.strip_edges() + "\n"


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


func nombre_clase(nombre : String) -> String:
	return datos_tipo()["prefijo_script"].capitalize().replace(" ", "") + pascal(nombre)


func ruta_script_para(nombre : String) -> String:
	return datos_tipo()["carpeta_scripts"] + datos_tipo()["prefijo_script"] + slug(nombre) + ".gd"


func clase_existe(clase : String) -> bool:
	return ClassDB.class_exists(clase) or not ProjectSettings.get_global_class_list().filter(func(info : Dictionary) -> bool: return info["class"] == clase).is_empty()


func avisar(texto : String) -> void:
	etiqueta_estado.text = texto


func crear_o_guardar() -> void:
	avisar("")
	if editando:
		guardar_existente()
	else:
		crear()


func crear_script_nuevo(nombre : String) -> Script:
	var ruta_script : String = ruta_script_para(nombre)
	var clase : String = nombre_clase(nombre)
	var script : Script
	if FileAccess.file_exists(ruta_script):
		avisar("Ya existe " + ruta_script)
		return null
	if clase_existe(clase):
		avisar("Ya existe la clase " + clase)
		return null
	script = escribir_script(ruta_script, generar_script(clase, datos_tipo()["clase_base"]))
	if not script:
		avisar("No se pudo escribir " + ruta_script)
	return script


func crear() -> void:
	var nombre : String = campo_nombre.text.strip_edges()
	var datos : Dictionary = datos_tipo()
	var script : Script = load(datos["script_base"])
	var ruta_resource : String = datos["carpeta_resources"] + slug(nombre) + ".tres"
	var contenedor : Resource
	var efecto : Resource
	if nombre.is_empty():
		avisar("Falta el nombre")
		return
	if FileAccess.file_exists(ruta_resource):
		avisar("Ya existe " + ruta_resource)
		return
	if not hooks_marcados().is_empty():
		script = crear_script_nuevo(nombre)
		if not script:
			return
	DirAccess.make_dir_recursive_absolute(datos["carpeta_resources"])
	if tiene_efectos():
		efecto = script.new()
		if not datos["nombre_en_efecto"].is_empty():
			efecto.set(datos["nombre_en_efecto"], nombre)
		efecto = guardar(efecto, ruta_resource.get_base_dir().path_join("efecto_" + ruta_resource.get_file()))
		contenedor = load(datos["script_contenedor"]).new()
		contenedor.set(datos["propiedad_efectos"], [efecto])
	else:
		contenedor = script.new()
	aplicar_campos(contenedor, nombre)
	contenedor = guardar(contenedor, ruta_resource)
	if script.resource_path != datos["script_base"]:
		EditorInterface.edit_script(script)
	EditorInterface.edit_resource(contenedor)
	editando = null
	limpiar_campos()
	armar_hooks([])
	armar_existentes()
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


func aplicar_campos(recurso : Resource, nombre : String) -> void:
	var datos : Dictionary = datos_tipo()
	recurso.nombre = nombre
	recurso.descripcion = campo_descripcion.text
	if datos["con_rareza"]:
		recurso.rareza = selector_rareza.selected
	recurso.set(datos["propiedad_icono"], selector_icono.edited_resource)
	if datos["con_textura"]:
		recurso.textura = selector_textura.edited_resource


func guardar_existente() -> void:
	var nombre : String = campo_nombre.text.strip_edges()
	var datos : Dictionary = datos_tipo()
	var objetivo : Resource = efecto_de(editando)
	var script : Script = script_editable(editando)
	var codigo : String
	var efectos : Array
	if nombre.is_empty():
		avisar("Falta el nombre")
		return
	if not objetivo:
		avisar("El item no tiene efecto para editar, agregale uno en el inspector")
		return
	if script and script.resource_path != datos["script_base"]:
		codigo = actualizar_script(script)
		if codigo != script.source_code:
			script.source_code = codigo
			ResourceSaver.save(script)
			script.reload()
			EditorInterface.get_resource_filesystem().update_file(script.resource_path)
		EditorInterface.edit_script(script)
	elif not hooks_marcados().is_empty():
		script = crear_script_nuevo(nombre)
		if not script:
			return
		objetivo = reemplazar_script(objetivo, script)
		if tiene_efectos():
			efectos = editando.get(datos["propiedad_efectos"])
			efectos[0] = objetivo
			editando.set(datos["propiedad_efectos"], efectos)
		else:
			editando = objetivo
		EditorInterface.edit_script(script)
	aplicar_campos(editando, nombre)
	if tiene_efectos():
		if not datos["nombre_en_efecto"].is_empty():
			objetivo.set(datos["nombre_en_efecto"], nombre)
		if not objetivo.resource_path.is_empty() and not objetivo.resource_path.contains("::"):
			guardar(objetivo, objetivo.resource_path)
	editando = guardar(editando, editando.resource_path)
	EditorInterface.edit_resource(editando)
	armar_existentes()
	avisar((etiqueta_estado.text + "\n").strip_edges() + "\nGuardado " + editando.resource_path)


func reemplazar_script(viejo : Resource, script : Script) -> Resource:
	var nuevo : Resource = script.new()
	for propiedad in viejo.get_property_list():
		if propiedad["usage"] & PROPERTY_USAGE_STORAGE and propiedad["name"] != "script":
			nuevo.set(propiedad["name"], viejo.get(propiedad["name"]))
	if not viejo.resource_path.is_empty() and not viejo.resource_path.contains("::"):
		nuevo.take_over_path(viejo.resource_path)
	return nuevo
