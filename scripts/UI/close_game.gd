extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit() # quit the game with a single key press
		

