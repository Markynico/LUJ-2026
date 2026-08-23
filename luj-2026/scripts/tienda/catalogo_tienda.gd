class_name CatalogoTienda
extends RefCounted

static func generar_catalogo_base() -> Array[ItemTienda]:
	var catalogo: Array[ItemTienda] = []
	
	# 1. Pelotita Espejismo
	var item1 = ItemTienda.new()
	item1.id = "pelotita_espejismo"
	item1.nombre = "Pelota Espejismo"
	item1.descripcion = "Se duplica en pleno vuelo creando réplicas de impacto."
	item1.precio = 60
	item1.rareza = ItemTienda.Rareza.RARO
	item1.tipo = ItemTienda.TipoItem.PELOTITA
	if ResourceLoader.exists("res://iconos_custom/pie_chart.svg"):
		item1.icono = load("res://iconos_custom/pie_chart.svg")
	if ResourceLoader.exists("res://scripts/pelotitas_custom/espejito1.tres"):
		item1.pelotita_recurso = load("res://scripts/pelotitas_custom/espejito1.tres")
	catalogo.append(item1)
	
	# 2. Pelotita Super Rebote
	var item2 = ItemTienda.new()
	item2.id = "pelotita_super_rebote"
	item2.nombre = "Pelota Dinámica"
	item2.descripcion = "Gran fuerza de rebote que arrasa con múltiples objetivos."
	item2.precio = 90
	item2.rareza = ItemTienda.Rareza.EPICO
	item2.tipo = ItemTienda.TipoItem.PELOTITA
	if ResourceLoader.exists("res://iconos_custom/gobot.svg"):
		item2.icono = load("res://iconos_custom/gobot.svg")
	if ResourceLoader.exists("res://scripts/pelotitas_custom/pelotita1.tres"):
		item2.pelotita_recurso = load("res://scripts/pelotitas_custom/pelotita1.tres")
	catalogo.append(item2)
	
	# 3. Garritas Ágiles (Mejora Pasiva)
	var item3 = ItemTienda.new()
	item3.id = "pasiva_garritas"
	item3.nombre = "Garritas Ágiles"
	item3.descripcion = "Aumenta la velocidad y precisión del disparo inicial."
	item3.precio = 75
	item3.rareza = ItemTienda.Rareza.RARO
	item3.tipo = ItemTienda.TipoItem.MEJORA_PASIVA
	if ResourceLoader.exists("res://iconos_custom/tap.svg"):
		item3.icono = load("res://iconos_custom/tap.svg")
	catalogo.append(item3)
	
	# 4. Pelotita Cósmica
	var item4 = ItemTienda.new()
	item4.id = "pelotita_cosmica"
	item4.nombre = "Pelota Cósmica"
	item4.descripcion = "Imbuida con energía cósmica y estela brillante resplandeciente."
	item4.precio = 140
	item4.rareza = ItemTienda.Rareza.LEGENDARIO
	item4.tipo = ItemTienda.TipoItem.PELOTITA
	if ResourceLoader.exists("res://iconos_custom/sphere.svg"):
		item4.icono = load("res://iconos_custom/sphere.svg")
	catalogo.append(item4)
	
	# 5. Lata de Atún Suprema (Consumible)
	var item5 = ItemTienda.new()
	item5.id = "consumible_atun"
	item5.nombre = "Lata de Atún"
	item5.descripcion = "Nutre al michi y otorga vidas o bolas adicionales de rescate."
	item5.precio = 45
	item5.rareza = ItemTienda.Rareza.COMUN
	item5.tipo = ItemTienda.TipoItem.CONSUMIBLE
	if ResourceLoader.exists("res://iconos_custom/heart.svg"):
		item5.icono = load("res://iconos_custom/heart.svg")
	catalogo.append(item5)
	
	return catalogo
