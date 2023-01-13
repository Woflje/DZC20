extends Node


var edit_mode = true

func _input(event):
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit() # quit the game with a single key press
