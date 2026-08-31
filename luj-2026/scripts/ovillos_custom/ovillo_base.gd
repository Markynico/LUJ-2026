class_name OvilloBase
extends Resource

@export var nombre : String = ""
##descripcion que se muestra en el popover del ovillo y en las tarjetas
@export_multiline var descripcion : String = ""
##sprite propio del tipo, opcional: si queda vacio se usa el sprite base de la escena
@export var sprite : Texture
##color con el que se tiñe el sprite base
@export var color : Color = Color.WHITE
##textura opcional que se dibuja por encima del ovillo, sin teñir
@export var decoracion : Texture
##textura opcional que se dibuja por delante de la decoracion, teñida con el color del ovillo
@export var decoracion_teñida : Texture
##material de brillo opcional que se dibuja sobre la decoracion
@export var material_brillo_decoracion : ShaderMaterial
##efecto de sonido que suena al romper este ovillo
@export var efecto_al_romper : EfectoDeSonido.Tipo = EfectoDeSonido.Tipo.ROMPER_OVILLO
##efecto de sonido que suena si este ovillo explota
@export var efecto_al_explotar : EfectoDeSonido.Tipo = EfectoDeSonido.Tipo.EXPLOSION
##escala visual y de colision del ovillo
@export var escala : float = 1.0
##ovillo como el que cuenta este tipo en estadisticas y desbloqueos, opcional
@export var contar_como : OvilloBase
##cantidad de monedas q obtendra el jugador cuando le peguemos a este ovillo
@export var cant_monedas : int = 0
##a la bola de pelos se le va a sumar este rebote extra, si no queremos q tenga rebote extra lo dejamos en cero y listo el posho (:
@export var rebote_extra : float = 10
@export var puntaje : int  = 1
#descripcion
@export var valor_spawn : float = 10.0
@export var color_numeros_impacto : Color
@export var efectos_al_recibir_impacto : Array[EfectosOvillo]
