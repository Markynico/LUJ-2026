@icon("res://iconos_custom/sphere.svg")
class_name BolaDePelos
extends RigidBody2D


@export_group("TIPO")
@export var tipo_pelotita : PelotitaBase #TODO revisar si de verdad lo necesito aca o directamente hacer export vars aca en el nodo

##diametro visual del sprite en pixeles, la textura se escala sola a este tamaño
@export var diametro_sprite : float = 22.0

@export_group("NODOS")
@export var sprite_bola: Sprite2D
@export var estela_movimiento : EstelaMovimiento

@export_group("SONIDO")
##cuanto sube el pitch del rebote por cada rebote acumulado
@export var incremento_pitch : float = 0.05
##tope del pitch extra acumulado por rebotes
@export var pitch_extra_maximo : float = 1.0

@export_group("FISICA")
##fraccion de la velocidad que conserva la bola al chocar con paredes y obstaculos, 1 = sin perdida
@export_range(0.0, 1.0) var amortiguacion_rebote : float = 0.85

@export_group("LIMITES")
##distancia fuera de los bordes del juego a la que se elimina la bola
@export var margen_borde : float = 200.0

var fue_duplicada : bool = false #se usa para efecto espejismo
var contador_rebotes : int = 0
var limites_juego : Rect2


var vector_x : int = randi_range(-300, 300) #estaba en -500 , 500 y el de abajo tmb
var vector_y : int = randi_range(-300, 300)

var impulso_pelotita_duplicada : Vector2 = Vector2(vector_x, vector_y)

func _ready() -> void:
	var tamanio_juego : Vector2 = Vector2(ProjectSettings.get_setting("display/window/size/viewport_width"), ProjectSettings.get_setting("display/window/size/viewport_height"))
	limites_juego = Rect2(Vector2.ZERO, tamanio_juego).grow(margen_borde)
	add_to_group("bolas_de_pelos")
	if GameManager.instancia_actual:
		tree_exited.connect(GameManager.instancia_actual.registrar_salida_de_bola, CONNECT_DEFERRED)
	estela_movimiento.gradient = tipo_pelotita.colores_estela
	sprite_bola.texture = tipo_pelotita.textura
	if sprite_bola.texture:
		sprite_bola.scale = Vector2.ONE * (diametro_sprite / sprite_bola.texture.get_width())
	
	for efecto in tipo_pelotita.efectos:
		efecto.al_crearse(self)
	if ReliquiasManager.bolas_atraviesan:
		activar_fantasma()


func activar_fantasma() -> void:
	var area : Area2D = Area2D.new()
	var colision : CollisionShape2D = CollisionShape2D.new()
	collision_mask &= ~2
	colision.shape = $CollisionShape2D.shape
	area.collision_layer = 0
	area.collision_mask = 2
	area.body_entered.connect(al_atravesar_ovillo)
	area.add_child(colision)
	add_child(area)


func al_atravesar_ovillo(body : Node) -> void:
	if body is Ovillo:
		body.recibir_impacto(self)

func normal_de_contacto(objeto : Node2D) -> Vector2:
	var estado : PhysicsDirectBodyState2D = PhysicsServer2D.body_get_direct_state(get_rid())
	var normal : Vector2
	for i in estado.get_contact_count():
		if estado.get_contact_collider_object(i) == objeto:
			normal = estado.get_contact_local_normal(i)
			if normal.dot(global_position - estado.get_contact_local_position(i)) < 0.0:
				normal = -normal
			return normal
	return objeto.global_position.direction_to(global_position)

func separar_del_contacto(objeto : Node2D) -> void:
	var estado : PhysicsDirectBodyState2D = PhysicsServer2D.body_get_direct_state(get_rid())
	var radio : float = $CollisionShape2D.shape.radius
	var normal : Vector2
	var punto : Vector2
	for i in estado.get_contact_count():
		if estado.get_contact_collider_object(i) == objeto:
			punto = estado.get_contact_local_position(i)
			normal = normal_de_contacto(objeto)
			if (global_position - punto).length() < radio:
				estado.transform.origin = punto + normal * radio
				global_position = punto + normal * radio
			return

func _on_body_shape_entered(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	if body is BolaDePelos: #evito rebote con otras bolas de pelos
		return
	if not body is Ovillo:
		contador_rebotes = 0
		if not ReliquiasManager.bolas_atraviesan:
			linear_velocity *= amortiguacion_rebote
	for efecto in tipo_pelotita.efectos:
		efecto.impactar_con_objeto(self, body)
	sonido_rebote()


func duplicar_pelotita():
	if fue_duplicada: #para solo duplicarla una sola vez
		return
	var pelotita_nueva : BolaDePelos = duplicate()
	pelotita_nueva.fue_duplicada = true #evito q la duplicada tambien se duplique
	get_parent().add_child(pelotita_nueva)
	pelotita_nueva.global_position = global_position
	pelotita_nueva.apply_impulse(impulso_pelotita_duplicada)
	fue_duplicada = true

func sonido_rebote():
	var pitch_extra : float = minf(contador_rebotes * incremento_pitch, pitch_extra_maximo)
	contador_rebotes += 1 #pq el sonido de rebote suma contador ?
	ReliquiasManager.al_rebotar()
	AudioManager.reproducir_sfx_en(EfectoDeSonido.Tipo.REBOTE, global_position, pitch_extra)


#eliminar la bola de pelos cuando sale de la pantalla
func _physics_process(_delta : float) -> void:
	if not limites_juego.has_point(global_position):
		queue_free()
