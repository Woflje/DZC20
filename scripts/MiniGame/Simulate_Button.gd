extends TextureRect

signal clicked  # Emitted when the button is clicked.

onready var simulate_texture = preload("res://assets/Textures/Overlay_components/simulation_button.png")
onready var simulate_exit_texture = preload("res://assets/Textures/Overlay_components/exit_sim.png")


func _gui_input(event):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == BUTTON_LEFT:
		emit_signal("clicked")


func _on_toggle_simulation(is_simulating: bool):
	if is_simulating:
		texture = simulate_exit_texture
	else:
		texture = simulate_texture
