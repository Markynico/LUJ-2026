class_name Resaltador
extends RefCounted

const PALABRAS : Dictionary = {
	"explosivo": {"color": Color("E33B2E"), "icono": "uid://dhf7cpyrxnlhx", "modo": "texto"},
	"catnip": {"color": Color("7DC43D"), "icono": "uid://4j10avmo472q", "modo": "texto"},
	"rebobinar": {"color": Color("A64FE3"), "icono": "uid://d1d8tmba154nk", "modo": "texto"},
	"monedas": {"color": Color("D9AD21"), "icono": "uid://cmgxgm42kfbke", "modo": "texto"},
	"ovillo_monedas": {"color": Color("d9a702ff"), "icono": "uid://csdrv6d6trs4a", "modo": "texto"},
	"ovillo_normal": {"color": Color("998042ff"), "icono": "uid://dbxxyb6slkgym", "modo": "texto"},
	"vida": {"color": Color("911328ff"), "icono": "uid://bfrl038m3jxcf", "modo": "texto", "escala": 0.7},
	"slot_vida": {"color": Color("8a7468ff"), "icono": "uid://cucbudcj05ymj", "modo": "texto", "escala": 1.5},
	"velocidad": {"color": Color("4b7dbfff"), "icono": "", "modo": "texto"},
	"gravedad": {"color": Color("7e70f4ff"), "icono": "", "modo": "texto"},
	"tiros": {"color": Color("2d9677ff"), "icono": "", "modo": "texto"},
	"rebote": {"color": Color("c95fb8ff"), "icono": "", "modo": "texto"},
	"facil": {"color": Color("6cc04a"), "icono": "uid://bp1qyy3ksenhp", "modo": "texto", "borde": Color(0.2, 0.8, 0.3)},
	"media": {"color": Color("e0a030"), "icono": "uid://dmd7g1ic6s8dq", "modo": "texto", "escala": 1.2, "borde": Color(1.0, 0.6, 0.1)},
	"dificil": {"color": Color("d84a3c"), "icono": "uid://dbh4cm5upkxnq", "modo": "texto", "escala": 1.5, "borde": Color(0.9, 0.15, 0.15)},
}
const TAMAÑO_ICONO : int = 24
const GROSOR_BORDE : int = 5
const RUTA_ICONOS_CON_BORDE : String = "res://resaltador/"

static var iconos_con_borde : Dictionary = {}


static func formatear(texto : String, escala_iconos : float = 1.0) -> String:
	var regex : RegEx = RegEx.new()
	var resultado : String = texto
	regex.compile("\\{([^}/:]+)(?::([^}/]+))?(?:/([^}]+))?\\}")
	for coincidencia in regex.search_all(texto):
		resultado = resultado.replace(coincidencia.get_string(0), reemplazo(coincidencia, escala_iconos))
	return resultado


static func reemplazo(coincidencia : RegExMatch, escala_iconos : float = 1.0) -> String:
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
		if datos.has("borde"):
			icono = icono_con_borde(clave, icono, datos["borde"])
		partes += etiqueta_icono(icono, datos.get("escala", 1.0) * escala_iconos)
	if modo == "texto" or modo == "ambos":
		partes += "[color=#%s]%s[/color]" % [datos["color"].to_html(false), visible]
	if partes.is_empty():
		partes = visible
	return partes


static func etiqueta_icono(ruta : String, escala : float = 1.0) -> String:
	var textura : Texture2D = load(ruta)
	var region : Rect2i
	var ancho : int = roundi(TAMAÑO_ICONO * escala)
	var alto : int = ancho
	if not textura:
		return ""
	region = textura.get_image().get_used_rect()
	if region.size.x > 0:
		alto = roundi(ancho * float(region.size.y) / float(region.size.x))
	return "[img width=%d height=%d region=%d,%d,%d,%d]%s[/img] " % [ancho, alto, region.position.x, region.position.y, region.size.x, region.size.y, ruta]


static func icono_con_borde(clave : String, ruta : String, color_borde : Color) -> String:
	var ruta_virtual : String = RUTA_ICONOS_CON_BORDE + clave + ".png"
	var textura : Texture2D
	var base : Image
	var silueta : Image
	var resultado : Image
	var textura_nueva : ImageTexture
	var tamaño : Vector2i
	if iconos_con_borde.has(ruta_virtual):
		return ruta_virtual
	textura = load(ruta)
	if not textura:
		return ruta
	base = textura.get_image()
	base.convert(Image.FORMAT_RGBA8)
	tamaño = base.get_size() + Vector2i.ONE * GROSOR_BORDE * 2
	silueta = Image.create(base.get_width(), base.get_height(), false, Image.FORMAT_RGBA8)
	for y in base.get_height():
		for x in base.get_width():
			silueta.set_pixel(x, y, Color(color_borde, base.get_pixel(x, y).a))
	resultado = Image.create(tamaño.x, tamaño.y, false, Image.FORMAT_RGBA8)
	for dx in [-1, 0, 1]:
		for dy in [-1, 0, 1]:
			resultado.blend_rect(silueta, Rect2i(Vector2i.ZERO, base.get_size()), Vector2i.ONE * GROSOR_BORDE + Vector2i(dx, dy) * GROSOR_BORDE)
	resultado.blend_rect(base, Rect2i(Vector2i.ZERO, base.get_size()), Vector2i.ONE * GROSOR_BORDE)
	textura_nueva = ImageTexture.create_from_image(resultado)
	textura_nueva.take_over_path(ruta_virtual)
	iconos_con_borde[ruta_virtual] = textura_nueva
	return ruta_virtual
