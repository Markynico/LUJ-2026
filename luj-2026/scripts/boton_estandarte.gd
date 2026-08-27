@tool
class_name BotonEstandarte
extends Button

##textura de la parte fija de arriba
@export var textura_fija : Texture2D:
	set(valor):
		textura_fija = valor
		if fija:
			fija.texture = valor
##textura de la tela que se despliega
@export var textura_tela : Texture2D:
	set(valor):
		textura_tela = valor
		if tela:
			tela.texture = valor
##posicion y de la tela cuando esta plegada
@export var y_escondida : float = -600.0
##posicion y de la tela cuando esta desplegada, compensa el corrimiento del recorte
@export var y_desplegada : float = 0.0
##segundos que tarda en desplegarse
@export var duracion : float = 0.3
@export var fija : TextureRect
@export var tela : TextureRect

var tween : Tween


func _ready() -> void:
	if textura_fija:
		fija.texture = textura_fija
	if textura_tela:
		tela.texture = textura_tela
	if Engine.is_editor_hint():
		return
	tela.position.y = y_escondida
	mouse_entered.connect(desplegar.bind(true))
	mouse_exited.connect(desplegar.bind(false))


func desplegar(abrir : bool) -> void:
	if tween:
		tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(tela, "position:y", y_desplegada if abrir else y_escondida, duracion)
	AudioManager.reproducir_sfx(EfectoDeSonido.Tipo.ESTANDARTE_ABRIR if abrir else EfectoDeSonido.Tipo.ESTANDARTE_CERRAR)
