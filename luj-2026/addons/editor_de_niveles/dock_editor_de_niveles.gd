@tool
class_name DockEditorDeNiveles
extends HBoxContainer

signal crear_forma(tipo : String)
signal nuevo_nivel
signal guardar_nivel(nombre : String)
signal cargar_nivel
signal agregar_recorrido
signal quitar_recorrido
signal simetria_cambiada(horizontal : bool, vertical : bool)
signal previsualizacion_cambiada(activa : bool)
signal seleccion_ovillos_cambiada(activa : bool)
signal eliminar_ovillos
signal restaurar_ovillos
signal probar_nivel(nombre : String)

@export var boton_rectangulo : Button
@export var boton_circulo : Button
@export var boton_path : Button
@export var boton_linea : Button
@export var boton_poligono : Button
@export var boton_obstaculo_rectangulo : Button
@export var boton_obstaculo_circulo : Button
@export var boton_agregar_recorrido : Button
@export var boton_quitar_recorrido : Button
@export var toggle_simetria_horizontal : CheckButton
@export var toggle_simetria_vertical : CheckButton
@export var toggle_previsualizar : CheckButton
@export var toggle_seleccionar_ovillos : CheckButton
@export var boton_eliminar_ovillos : Button
@export var boton_restaurar_ovillos : Button
@export var boton_probar : Button
@export var boton_nuevo : Button
@export var boton_guardar : Button
@export var boton_cargar : Button
@export var campo_nombre : LineEdit


func _ready() -> void:
	boton_rectangulo.pressed.connect(crear_forma.emit.bind("rectangulo"))
	boton_circulo.pressed.connect(crear_forma.emit.bind("circulo"))
	boton_path.pressed.connect(crear_forma.emit.bind("path"))
	boton_linea.pressed.connect(crear_forma.emit.bind("linea"))
	boton_poligono.pressed.connect(crear_forma.emit.bind("poligono"))
	boton_obstaculo_rectangulo.pressed.connect(crear_forma.emit.bind("obstaculo_rectangulo"))
	boton_obstaculo_circulo.pressed.connect(crear_forma.emit.bind("obstaculo_circulo"))
	boton_agregar_recorrido.pressed.connect(agregar_recorrido.emit)
	boton_quitar_recorrido.pressed.connect(quitar_recorrido.emit)
	toggle_simetria_horizontal.toggled.connect(emitir_simetria)
	toggle_simetria_vertical.toggled.connect(emitir_simetria)
	toggle_previsualizar.toggled.connect(previsualizacion_cambiada.emit)
	toggle_seleccionar_ovillos.toggled.connect(seleccion_ovillos_cambiada.emit)
	boton_eliminar_ovillos.pressed.connect(eliminar_ovillos.emit)
	boton_restaurar_ovillos.pressed.connect(restaurar_ovillos.emit)
	boton_probar.pressed.connect(func(): probar_nivel.emit(campo_nombre.text))
	boton_nuevo.pressed.connect(nuevo_nivel.emit)
	boton_guardar.pressed.connect(func(): guardar_nivel.emit(campo_nombre.text))
	boton_cargar.pressed.connect(cargar_nivel.emit)


func mostrar_nombre(nombre : String) -> void:
	campo_nombre.text = nombre


func emitir_simetria(presionado : bool) -> void:
	simetria_cambiada.emit(toggle_simetria_horizontal.button_pressed, toggle_simetria_vertical.button_pressed)
