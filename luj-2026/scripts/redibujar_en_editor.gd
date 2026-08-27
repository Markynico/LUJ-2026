@tool
class_name RedibujarEnEditor
extends CanvasItem


func _process(delta : float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()
