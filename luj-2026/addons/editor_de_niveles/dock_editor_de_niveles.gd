@tool
class_name DockEditorDeNiveles
extends VBoxContainer

signal crear_forma(tipo : String)
signal guardar_nivel(nombre : String)
signal cargar_nivel
signal agregar_recorrido
signal quitar_recorrido

@export var boton_rectangulo : Button
@export var boton_circulo : Button
@export var boton_path : Button
@export var boton_agregar_recorrido : Button
@export var boton_quitar_recorrido : Button
@export var boton_guardar : Button
@export var boton_cargar : Button
@export var campo_nombre : LineEdit


func _ready() -> void:
	boton_rectangulo.pressed.connect(crear_forma.emit.bind("rectangulo"))
	boton_circulo.pressed.connect(crear_forma.emit.bind("circulo"))
	boton_path.pressed.connect(crear_forma.emit.bind("path"))
	boton_agregar_recorrido.pressed.connect(agregar_recorrido.emit)
	boton_quitar_recorrido.pressed.connect(quitar_recorrido.emit)
	boton_guardar.pressed.connect(func(): guardar_nivel.emit(campo_nombre.text))
	boton_cargar.pressed.connect(cargar_nivel.emit)


func mostrar_nombre(nombre : String) -> void:
	campo_nombre.text = nombre
