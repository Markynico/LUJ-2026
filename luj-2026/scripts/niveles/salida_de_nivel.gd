@tool
class_name SalidaDeNivel
extends Area2D

signal elegida(salida : SalidaDeNivel)

static var regiones_iconos : Dictionary = {}

##tipo de sala a la que lleva esta salida
@export var tipo : TipoDeSala.Tipo = TipoDeSala.Tipo.NORMAL:
	set(valor):
		tipo = valor
		queue_redraw()
##ancho y alto del area
@export var tamaño : Vector2 = Vector2(100.0, 200.0):
	set(valor):
		tamaño = valor.max(Vector2.ONE)
		actualizar_forma()
@export var colision : CollisionShape2D
##segundos que dura el fade in al aparecer
@export var duracion_fade : float = 0.4
##ancho en pixeles del icono de la sala, el alto es proporcional
@export var ancho_icono : float = 48.0


func _ready() -> void:
	actualizar_forma()
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not Engine.is_editor_hint():
		modulate.a = 0.0
		monitoring = false


func aparecer(retraso : float = 0.0) -> void:
	var tween : Tween = create_tween()
	tween.tween_interval(retraso)
	tween.tween_callback(func(): monitoring = true)
	tween.tween_property(self, "modulate:a", 1.0, duracion_fade)

func actualizar_forma() -> void:
	if not colision:
		return
	if not colision.shape:
		colision.shape = RectangleShape2D.new()
	colision.shape.size = tamaño
	colision.position = Vector2(0, -tamaño.y * 0.5)
	queue_redraw()


func _draw() -> void:
	var icono : Texture2D = TipoDeSala.ICONOS.get(tipo)
	var alto : float
	var region : Rect2
	var color : Color = TipoDeSala.COLORES[tipo]
	var transparente : Color = Color(color, 0.0)
	var puntos : PackedVector2Array = PackedVector2Array([
		Vector2(-tamaño.x * 0.5, -tamaño.y),
		Vector2(tamaño.x * 0.5, -tamaño.y),
		Vector2(tamaño.x * 0.5, 0.0),
		Vector2(-tamaño.x * 0.5, 0.0),
	])
	var colores : PackedColorArray = PackedColorArray([transparente, transparente, color, color])
	draw_polygon(puntos, colores)
	if icono:
		region = region_de(icono)
		alto = ancho_icono * region.size.y / region.size.x
		draw_texture_rect_region(icono, Rect2(-ancho_icono * 0.5, -tamaño.y * 0.5 - alto * 0.5, ancho_icono, alto), region)


static func region_de(icono : Texture2D) -> Rect2:
	if not regiones_iconos.has(icono):
		regiones_iconos[icono] = Rect2(icono.get_image().get_used_rect())
	return regiones_iconos[icono]


func _on_body_entered(body : Node2D) -> void:
	elegida.emit(self)
