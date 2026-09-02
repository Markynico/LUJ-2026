@tool
extends EditorPlugin

const ESCENA_DOCK := preload("res://addons/creador_de_items/dock_creador_de_items.tscn")

var dock : DockCreadorDeItems


func _enter_tree() -> void:
	dock = ESCENA_DOCK.instantiate()
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, dock)


func _exit_tree() -> void:
	remove_control_from_docks(dock)
	dock.queue_free()
