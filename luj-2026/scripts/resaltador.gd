class_name Resaltador
extends RefCounted

const PALABRAS : Dictionary = {
	"explosivo": {"color": Color("E33B2E"), "icono": "uid://dhf7cpyrxnlhx", "modo": "texto"},
	"catnip": {"color": Color("7DC43D"), "icono": "uid://4j10avmo472q", "modo": "texto"},
	"rebobinar": {"color": Color("A64FE3"), "icono": "uid://bd7syc7ij2y2t", "modo": "texto"},
	"monedas": {"color": Color("D9AD21"), "icono": "uid://cmgxgm42kfbke", "modo": "texto"},
	"ovillo_monedas": {"color": Color("d9a702ff"), "icono": "uid://csdrv6d6trs4a", "modo": "texto"},
	"ovillo_normal": {"color": Color("998042ff"), "icono": "uid://dbxxyb6slkgym", "modo": "texto"},
	"vida": {"color": Color("911328ff"), "icono": "", "modo": "texto"},
	"velocidad": {"color": Color("4b7dbfff"), "icono": "", "modo": "texto"},
	"gravedad": {"color": Color("7e70f4ff"), "icono": "", "modo": "texto"},
	"tiros": {"color": Color("2d9677ff"), "icono": "", "modo": "texto"},
	"rebote": {"color": Color("c95fb8ff"), "icono": "", "modo": "texto"},
}
const TAMAÑO_ICONO : int = 24


static func formatear(texto : String) -> String:
	var regex : RegEx = RegEx.new()
	var resultado : String = texto
	regex.compile("\\{([^}/:]+)(?::([^}/]+))?(?:/([^}]+))?\\}")
	for coincidencia in regex.search_all(texto):
		resultado = resultado.replace(coincidencia.get_string(0), reemplazo(coincidencia))
	return resultado


static func reemplazo(coincidencia : RegExMatch) -> String:
	var clave : String = coincidencia.get_string(1)
	var modo : String = coincidencia.get_string(2)
	var visible : String = coincidencia.get_string(3)
	var datos : Dictionary = {}
	var partes : String = ""
	var icono : String = ""
	if visible.is_empty():
		visible = clave
	if not PALABRAS.has(clave):
		push_warning("Resaltador: palabra clave desconocida '" + clave + "'")
		return visible
	datos = PALABRAS[clave]
	if modo.is_empty():
		modo = datos.get("modo", "texto")
	icono = datos.get("icono", "")
	if (modo == "icono" or modo == "ambos") and not icono.is_empty():
		partes += etiqueta_icono(icono)
	if modo == "texto" or modo == "ambos":
		partes += "[color=#%s]%s[/color]" % [datos["color"].to_html(false), visible]
	if partes.is_empty():
		partes = visible
	return partes


static func etiqueta_icono(ruta : String) -> String:
	var textura : Texture2D = load(ruta)
	var region : Rect2i
	var alto : int = TAMAÑO_ICONO
	if not textura:
		return ""
	region = textura.get_image().get_used_rect()
	if region.size.x > 0:
		alto = roundi(TAMAÑO_ICONO * float(region.size.y) / float(region.size.x))
	return "[img width=%d height=%d region=%d,%d,%d,%d]%s[/img] " % [TAMAÑO_ICONO, alto, region.position.x, region.position.y, region.size.x, region.size.y, ruta]
