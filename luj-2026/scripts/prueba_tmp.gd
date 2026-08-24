extends SceneTree

func _init() -> void:
	var cargador := CargadorDeNivel.new()
	root.add_child(cargador)
	await process_frame
	var rect := cargador.crear_forma("rectangulo")
	rect.tamaño = Vector2(200, 100)
	var circ := cargador.crear_forma("obstaculo_circulo")
	circ.radio = 50.0
	var path := cargador.crear_forma("path")
	path.obtener_curva().add_point(Vector2.ZERO)
	path.obtener_curva().add_point(Vector2(100, 0))
	await process_frame
	var datos := cargador.exportar_nivel("t")
	cargador.construir_nivel(datos)
	await process_frame
	print("roundtrip: ", cargador.obtener_formas().map(func(f): return f.name))
	print("puntos rect: ", rect.obtener_puntos().size())
	quit()
