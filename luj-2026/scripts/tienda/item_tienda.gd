class_name ItemTienda
extends Resource

enum Rareza { COMUN, RARO, EPICO, LEGENDARIO }
enum TipoItem { PELOTITA, MEJORA_PASIVA, CONSUMIBLE }

@export var id: String = ""
@export var nombre: String = "Pelotita Misteriosa"
@export_multiline var descripcion: String = "Efecto especial al impactar o rebotar."
@export var icono: Texture2D
@export var precio: int = 50
@export var rareza: Rareza = Rareza.COMUN
@export var tipo: TipoItem = TipoItem.PELOTITA
@export var pelotita_recurso: PelotitaBase
@export var comprado_unico: bool = true

static func get_color_rareza(r: Rareza) -> Color:
	match r:
		Rareza.COMUN:
			return Color(0.75, 0.78, 0.85) # Gris plateado
		Rareza.RARO:
			return Color(0.25, 0.65, 0.95) # Azul celeste
		Rareza.EPICO:
			return Color(0.72, 0.35, 0.95) # Púrpura brillante
		Rareza.LEGENDARIO:
			return Color(0.98, 0.75, 0.2) # Oro brillante
		_:
			return Color.WHITE

static func get_nombre_rareza(r: Rareza) -> String:
	match r:
		Rareza.COMUN:
			return "COMÚN"
		Rareza.RARO:
			return "RARO"
		Rareza.EPICO:
			return "ÉPICO"
		Rareza.LEGENDARIO:
			return "LEGENDARIO"
		_:
			return "COMÚN"
