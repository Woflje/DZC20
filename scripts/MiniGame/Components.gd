extends GridContainer

onready var template_scene = preload("res://scenes/item_slot.tscn")

var inv_item_list = [
	["wire", "res://assets/Textures/Overlay_components/wire.png"],
	["lamp", "res://assets/Textures/Overlay_components/lamp.png"],
	["switch", "res://assets/Textures/Overlay_components/switch_open.png"],
	["resistor", "res://assets/Textures/Overlay_components/resistor.png"],
	#["diode", "res://assets/Textures/Overlay_components/diode.png"],
	["breaker_left", "res://assets/Textures/Overlay_components/double_breaker_switch_left.png"],
	["breaker_right", "res://assets/Textures/Overlay_components/double_breaker_switch_right.png"],
	#["resistor", "res://assets/Textures/Overlay_components/resistor.png"],
	["LED", "res://assets/Textures/Overlay_components/LED.png"],
	#["double_breaker_switch", "res://assets/Textures/Overlay_components/double_breaker_switch.png"],
	# ["switch_closed","res://assets/Textures/Overlay_components/switch_closed.png"],
	["transformator", "res://assets/Textures/Overlay_components/transformator.png"],
	# ["power_scource_pos","res://icon.png"],
	#["power_scource_neg","res://What-Do-Electrical-Wire-Colors-Mean.jpg"],
]

var default_texture = "res://assets/Textures/Overlay_components/grid block_2.png"


func _ready():
	var h_seperation = get_constant("hseparation")
	var size = rect_size[0] / columns - h_seperation

	for item in inv_item_list:
		add_child(create_item(item[0], item[1], size))
	pass


func create_item(name: String, icon: String, size: float):
	var item = template_scene.instance()

	item._set_default_texture(default_texture)
	item._add_tag(name)
	item._update_texture(icon)
	item.infinate_sink = true
	item._panel_components()

	item.rect_min_size = Vector2(size, size)

	return item


# If the simulation is running, change the opacity of the children
func _on_toggle_simulation(is_simulating: bool):
	for child in get_children():
		if is_simulating:
			child.modulate = Color(1, 1, 1, 0.5)
		else:
			child.modulate = Color(1, 1, 1, 1)
	
