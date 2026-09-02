extends CanvasLayer

##pergamino que muestra la explicacion
@export var pergamino : PergaminoInfo
##espera antes de mostrar, para que no parpadee al pasar el mouse
@export var temporizador : Timer
##distancia entre el mouse y el pergamino
@export var margen : Vector2 = Vector2(18.0, 18.0)

var clave_pendiente : String = ""
var titulo_pendiente : String = ""
var texto_pendiente : String = ""


func _ready() -> void:
	temporizador.timeout.connect(mostrar_pendiente)


func _process(delta : float) -> void:
	if pergamino.visible:
		posicionar()


func mostrar(clave : String) -> void:
	if Resaltador.explicacion(clave).is_empty():
		return
	clave_pendiente = clave
	temporizador.start()


func mostrar_texto(titulo : String, texto : String) -> void:
	clave_pendiente = ""
	titulo_pendiente = titulo
	texto_pendiente = texto
	temporizador.start()


func mostrar_pendiente() -> void:
	var datos : Dictionary = Resaltador.explicacion(clave_pendiente)
	if not clave_pendiente.is_empty():
		if datos.is_empty():
			return
		titulo_pendiente = datos["titulo"]
		texto_pendiente = datos["texto"]
	pergamino.set_texto_mecanica(Resaltador.formatear(titulo_pendiente), Resaltador.formatear(texto_pendiente))
	pergamino.set_activo(true)
	posicionar()


func ocultar() -> void:
	temporizador.stop()
	clave_pendiente = ""
	if pergamino.visible:
		pergamino.set_activo(false)


func posicionar() -> void:
	var limite : Vector2 = get_viewport().get_visible_rect().size
	var tamaño : Vector2
	pergamino.size = pergamino.get_combined_minimum_size()
	tamaño = pergamino.size * pergamino.scale
	var posicion : Vector2 = get_viewport().get_mouse_position() + margen
	if posicion.x + tamaño.x > limite.x:
		posicion.x = get_viewport().get_mouse_position().x - margen.x - tamaño.x
	if posicion.y + tamaño.y > limite.y:
		posicion.y = get_viewport().get_mouse_position().y - margen.y - tamaño.y
	pergamino.position = posicion.clamp(Vector2.ZERO, (limite - tamaño).max(Vector2.ZERO))
