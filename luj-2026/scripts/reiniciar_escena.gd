extends Node

#lo agrego aca para el showcase, pero dsp habria que sacarlo o integrarlo en el hud
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("r"):
		print("vamo a reiniciar la escena actual mi loco")
		get_tree().reload_current_scene()
