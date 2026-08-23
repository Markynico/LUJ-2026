@tool
class_name DockEditorDeNiveles
extends VBoxContainer

signal crear_forma(tipo : String)
signal guardar_nivel(nombre : String)
signal cargar_nivel

@export var boton_rectangulo : Button
@export var boton_guardar : Button
@export var boton_cargar : Button
@export var campo_nombre : LineEdit


func _ready() -> void:
	boton_rectangulo.pressed.connect(crear_forma.emit.bind("rectangulo"))
	boton_guardar.pressed.connect(func(): guardar_nivel.emit(campo_nombre.text))
	boton_cargar.pressed.connect(cargar_nivel.emit)


func mostrar_nombre(nombre : String) -> void:
	campo_nombre.text = nombre
