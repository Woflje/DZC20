extends TextureRect

var close_button_texture = "res://assets/Textures/Overlay_components/close_button.png"
var complete_button_off_texture = "res://assets/Textures/Overlay_components/complete_button_off.png"
var complete_button_on_texture = "res://assets/Textures/Overlay_components/complete_button_on.png"

func _on_toggle_simulation(is_simulating: bool):
	if is_simulating:
		texture = load(complete_button_off_texture)
	else:
		texture = load(close_button_texture)
