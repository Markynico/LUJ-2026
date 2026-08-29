class_name OvilloBase
extends Resource

@export var nombre : String = ""
##sprite propio del tipo, opcional: si queda vacio se usa el sprite base de la escena
@export var sprite : Texture
##color con el que se tiñe el sprite base
@export var color : Color = Color.WHITE
##textura opcional que se dibuja por encima del ovillo
@export var decoracion : Texture
##efecto de sonido que suena al romper este ovillo
@export var efecto_al_romper : EfectoDeSonido.Tipo = EfectoDeSonido.Tipo.ROMPER_OVILLO
##cantidad de monedas q obtendra el jugador cuando le peguemos a este ovillo
@export var cant_monedas : int = 0
##a la bola de pelos se le va a sumar este rebote extra, si no queremos q tenga rebote extra lo dejamos en cero y listo el posho (:
@export var rebote_extra : float = 10
@export var puntaje : int  = 1
#descripcion
@export var valor_spawn : float = 10.0
@export var color_numeros_impacto : Color
@export var efectos_al_recibir_impacto : Array[EfectosOvillo]
