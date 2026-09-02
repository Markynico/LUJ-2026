@icon("res://assets/sprite_ovillos/Ovillo verde.png")
class_name Ovillo
extends StaticBody2D

@export var tipo_ovillo : OvilloBase

@export_group("NODOS")
@export var forma_colision : CollisionShape2D
@export var sprite_normal : Sprite2D #el sprite normal es el q va a contener el shader de titilar antes de explotar
@export var sprite_desactivado : Sprite2D
@export var sprite_decoracion : Sprite2D
@export var sprite_decoracion_teñida : Sprite2D
@export var sprite_brillo_decoracion : Sprite2D
@export var pergamino_info : PergaminoInfo
@export var numero_impacto : NumeroImpacto
@export var sprite_estado : Sprite2D

signal ovillo_desactivado(ovillo: Ovillo)
signal rebobinar_bola(bola_de_pelos : BolaDePelos)

@export var shader_titilar : ShaderMaterial
var tween : Tween
var activado : bool = true
var bola_que_impacto : BolaDePelos = null

var multiplicador : int = 1 #para ovillo_catnip
var estados : Array[EstadoOvillo] = []
var ultimo_resultado : ResultadoImpacto

func _ready() -> void:
	add_to_group("ovillos")
	if sprite_desactivado:
		sprite_desactivado.hide()
	if tipo_ovillo:
		scale = Vector2.ONE * tipo_ovillo.escala
		if sprite_normal:
			if tipo_ovillo.sprite:
				sprite_normal.texture = tipo_ovillo.sprite
			sprite_normal.self_modulate = tipo_ovillo.color
		if sprite_decoracion:
			if tipo_ovillo.decoracion:
				sprite_decoracion.texture = tipo_ovillo.decoracion
			else:
				sprite_decoracion.hide()
		if sprite_brillo_decoracion:
			if tipo_ovillo.material_brillo_decoracion:
				sprite_brillo_decoracion.texture = sprite_normal.texture
				sprite_brillo_decoracion.material = tipo_ovillo.material_brillo_decoracion
				sprite_brillo_decoracion.show()
			else:
				sprite_brillo_decoracion.hide()
		if sprite_decoracion_teñida:
			if tipo_ovillo.decoracion_teñida:
				sprite_decoracion_teñida.texture = tipo_ovillo.decoracion_teñida
				sprite_decoracion_teñida.self_modulate = tipo_ovillo.color
			else:
				sprite_decoracion_teñida.hide()
		if pergamino_info:
			pergamino_info.set_texto_ovillo(tipo_ovillo)
	
	# Auto-registrarse en GameManager
	if GameManager.instancia_actual:
		GameManager.instancia_actual.registrar_ovillo(self)
		GameManager.instancia_actual.gato_lanza_bola.connect(al_empezar_turno)
	ReliquiasManager.al_spawnear_ovillo(self)


func fuentes_estados() -> Array:
	var resultado : Array = []
	for estado in estados:
		resultado.append_array(estado.fuentes())
	return resultado


func tiene_estado(nombre : String) -> bool:
	for estado in estados:
		if estado.nombre == nombre:
			return true
	return false


func aplicar_estado(plantilla : EstadoOvillo) -> EstadoOvillo:
	var estado : EstadoOvillo
	if not plantilla or not activado or tiene_estado(plantilla.nombre):
		return null
	estado = plantilla.duplicate(true)
	estado.iniciar()
	estados.append(estado)
	for fuente in estado.fuentes():
		fuente.al_aplicar(self)
	actualizar_visual_estados()
	return estado


func quitar_estado(estado : EstadoOvillo) -> void:
	if not estado in estados:
		return
	estados.erase(estado)
	for fuente in estado.fuentes():
		fuente.al_quitar(self)
	actualizar_visual_estados()


func actualizar_visual_estados() -> void:
	var tinte : Color = Color.WHITE
	if sprite_estado:
		sprite_estado.visible = false
		for estado in estados:
			if estado.decoracion:
				sprite_estado.texture = estado.decoracion
				sprite_estado.visible = true
	for estado in estados:
		tinte *= estado.color_tinte
	if sprite_normal:
		sprite_normal.modulate = tinte


func al_empezar_turno() -> void:
	for estado in estados.duplicate():
		for fuente in estado.fuentes():
			fuente.al_empezar_turno(self)
		if estado.pasar_turno():
			quitar_estado(estado)


func simular_impacto(tipo_bola : PelotitaBase) -> ResultadoImpacto:
	var resultado : ResultadoImpacto = ResultadoImpacto.new()
	for fuente in fuentes_estados():
		fuente.resolver_impacto(self, tipo_bola, resultado)
	return resultado


func aplicar_resultado(resultado : ResultadoImpacto) -> void:
	for estado in resultado.gastar_carga:
		if estado.gastar_carga() and not estado in resultado.quitar:
			resultado.quitar.append(estado)
	for estado in resultado.quitar:
		quitar_estado(estado)

func recibir_impacto(bola_pelos : BolaDePelos = null) -> void: # Se llama desde la bola de pelos al impactar
	if not activado:
		return
	bola_que_impacto = bola_pelos
	ultimo_resultado = simular_impacto(bola_pelos.tipo_pelotita if bola_pelos else null)
	aplicar_resultado(ultimo_resultado)
	if ultimo_resultado.romper:
		romper()


func recibir_explosion() -> void:
	var resultado : ResultadoImpacto = ResultadoImpacto.new()
	if not activado:
		return
	bola_que_impacto = null
	for fuente in fuentes_estados():
		fuente.resolver_explosion(self, resultado)
	aplicar_resultado(resultado)
	if resultado.romper:
		romper()


func romper() -> void:
	desactivar_ovillo()
	numero_impacto.iniciar_numero_impacto(obtener_puntaje()) #le cambie monedas x puntaje
	for efecto in tipo_ovillo.efectos_al_recibir_impacto:
		efecto.al_recibir_impacto(self)
	for fuente in fuentes_estados():
		fuente.al_romperse(self)


func al_rebotar_bola(bola : BolaDePelos) -> void:
	for fuente in fuentes_estados():
		fuente.al_rebotar_bola(self, bola)


#forzar github
	#numero_impacto.iniciar_numero_impacto(tipo_ovillo.cant_monedas) #holi aca poner puntaje en vez de monedas
	#for efecto in tipo_ovillo.efectos_al_recibir_impacto:
	#	efecto.al_recibir_impacto(self)
		#emitir dar monedas tipo_ovillo.cantidadmondedas
	#	pass


func desactivar_ovillo() -> void:
	if not activado:
		return
	activado = false
	if forma_colision:
		forma_colision.set_deferred("disabled", true)
	if sprite_normal:
		sprite_normal.hide()
	if sprite_desactivado:
		sprite_desactivado.show()
	if tipo_ovillo:
		AudioManager.reproducir_sfx_en(tipo_ovillo.efecto_al_romper, global_position)

	ovillo_desactivado.emit(self)
	
	# Notificar a GameManager
	if GameManager.instancia_actual:
		GameManager.instancia_actual.registrar_ovillo_destruido(self)

func reactivar_ovillo() -> void:
	if activado:
		return
	activado = true
	if forma_colision:
		forma_colision.set_deferred("disabled", false)
	if sprite_normal:
		sprite_normal.show()
	if sprite_desactivado:
		sprite_desactivado.hide()


func explotar(nodo_explosion : Explosion): #lo llamo en el EfectoExplosion
	if ReliquiasManager.explosion_instantanea:
		AudioManager.reproducir_sfx(tipo_ovillo.efecto_al_explotar)
		nodo_explosion.activar_explosion()
		return
	var reproductor_mecha : AudioStreamPlayer = AudioManager.reproducir_sfx(EfectoDeSonido.Tipo.MECHA)
	sprite_normal.show() #lo muestro a proposito pq cuando lo desactivo se esconde, es solo visual
	sprite_desactivado.hide()
	sprite_normal.material = shader_titilar.duplicate() #ahora sprite tiene el shader, onda adentro del material esta el shader
	var shader_real : ShaderMaterial = sprite_normal.material
	animacion_titilar(shader_real)
	await tween.finished
	sprite_normal.hide() #los vuelvo a esconder como si se hubiera desactivado recien ahora
	sprite_desactivado.show()
	AudioManager.detener_sfx(reproductor_mecha)
	AudioManager.reproducir_sfx(tipo_ovillo.efecto_al_explotar)
	nodo_explosion.activar_explosion()
	tween.kill()

func duplicar_recompensas() -> void: #la llama efecto_ovillo_catnip
	if !activado:
		return
	#print("MULTIPLICÓ")
	if ReliquiasManager.catnip_stackeable:
		multiplicador *= 2
	else:
		multiplicador = 2


func fin_duplicar() -> void:
	if !activado:
		return
	if ReliquiasManager.catnip_stackeable:
		multiplicador = maxi(1, multiplicador / 2)
	else:
		multiplicador = 1

func obtener_puntaje () -> int:
	if not tipo_ovillo:
		return 0
	#print(name, " puntaje: ", tipo_ovillo.puntaje, " x ", multiplicador)
	return pasar_por_estados("modificar_puntaje", roundi(tipo_ovillo.puntaje * multiplicador * ReliquiasManager.multiplicador_puntos_para(tipo_ovillo)))

func obtener_monedas () -> int:
	if not tipo_ovillo:
		return 0
	return pasar_por_estados("modificar_monedas", roundi(tipo_ovillo.cant_monedas * multiplicador * ReliquiasManager.multiplicador_monedas_para(tipo_ovillo)))


func pasar_por_estados(metodo : String, valor : int) -> int:
	for fuente in fuentes_estados():
		valor = fuente.call(metodo, self, valor)
	return valor

func congelar() -> void:
	pass


func animacion_titilar(shader_real : ShaderMaterial):
	shader_real.set_shader_parameter("time", 0.0) #inicializo en 0.0
	tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(shader_real,"shader_parameter/time",1.0,tipo_ovillo.duracion_mecha * ReliquiasManager.multiplicador_duracion_para("mecha"))

func convertir_explosivo(ovillo : Ovillo, efecto_bomba : OvilloBase) -> void:
	var bomba : OvilloBase = ReliquiasManager.reemplazo_para(efecto_bomba)
	if ovillo.tipo_ovillo == bomba:
		return
	sprite_decoracion.show()
	sprite_decoracion.texture = bomba.decoracion #vemos si le agrega la mecha de explosivo
	ovillo.cambiar_tipo(bomba)

func cambiar_tipo(nuevo_tipo : OvilloBase) -> void:
	reactivar_ovillo()
	tipo_ovillo = nuevo_tipo
	scale = Vector2.ONE * tipo_ovillo.escala
	if sprite_normal and tipo_ovillo.sprite:
		sprite_normal.texture = tipo_ovillo.sprite
