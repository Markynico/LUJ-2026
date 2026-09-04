class_name DatosGato
extends Resource

##nombre del gato
@export var nombre : String = ""
##textura que se muestra en el menu y en las notificaciones de desbloqueo
@export var textura : Texture2D
##descripcion que aparece en el cartel de seleccion
@export_multiline var descripcion : String = ""
##posicion en el exhibidor del menu, menor primero
@export var orden : int = 0

@export_group("Apariencia en juego")
@export var imagen_normal : Texture2D
@export var imagen_bolita : Texture2D
@export var imagen_orgulloso : Texture2D
##escala del sprite cuando muestra la imagen normal
@export var escala_normal : float = 0.32
##escala del sprite cuando muestra la imagen bolita
@export var escala_bolita : float = 0.26
##animaciones del gato: blink, escupir_bola, idle, orgulloso y RESET
@export var animaciones : AnimationLibrary
##tinte que se aplica a todos los sprites del gato, placeholder para diferenciar gatos con el mismo arte
@export var tinte : Color = Color.WHITE

@export_group("Otras pantallas")
##frames del gato que descansa en la tienda
@export var frames_tienda : SpriteFrames
##sprite del fin de run cuando se gana
@export var sprite_victoria : Texture2D
##sprite del fin de run cuando se pierde
@export var sprite_derrota : Texture2D

@export_group("Stats")
##multiplicador de la distancia al mouse al lanzar el gato
@export var fuerza_disparo : float = 1.0
##ovillos que puede romper el gato al ser lanzado
@export var impactos_maximos : int = 4

@export_group("Efectos")
##efectos pasivos del gato, usan los mismos hooks que las reliquias
@export var efectos : Array[EfectoReliquia] = []

@export_group("Desbloqueo")
##condiciones que deben cumplirse todas para desbloquear el gato, vacio = desbloqueado de entrada
@export var condiciones_desbloqueo : Array[CondicionDesbloqueo] = []


func fuentes() -> Array:
	var resultado : Array = []
	for efecto in efectos:
		if efecto:
			resultado.append(efecto)
	return resultado
