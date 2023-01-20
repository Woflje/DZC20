extends TextureRect

var close_button_texture = "res://assets/Textures/Overlay_components/close_button.png"
var complete_button_off_texture = "res://assets/Textures/Overlay_components/complete_button_off.png"
var complete_button_on_texture = "res://assets/Textures/Overlay_components/complete_button_on.png"
var is_level_complete = false

func _input(_event):
	if Input.is_action_pressed("ui_cancel"):
		close()

func _gui_input(event):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == BUTTON_LEFT:
		close()

func close():
	$ButtonSFX.play()
	var main = get_tree().get_root().find_node("Main", true, false)
	main._load_overworld(true, is_level_complete)



func _on_puzzle_completed():
	texture = load(complete_button_on_texture)
	is_level_complete = true
