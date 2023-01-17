extends GridContainer

onready var template_scene = preload("res://scenes/item_slot.tscn")

var default_texture = "res://assets/Textures/Overlay_components/grid block_2.png"


func _ready():
	var h_seperation = get_constant("hseparation")
	var size = rect_size[0] / columns - h_seperation

	for i in columns * columns:
		add_child(create_item(size))

	# Make (0, 2) and (0, 5) the power source
	update_powersource(
		0, 2, "power_source_pos", "res://assets/Textures/Overlay_components/+_powersupply.png"
	)
	update_powersource(
		0, 5, "power_source_neg", "res://assets/Textures/Overlay_components/-_powersupply.png"
	)

	pass


func create_item(size: float):
	var item = template_scene.instance()

	item._set_default_texture(default_texture)
	item._panel_circuit()

	item.rect_min_size = Vector2(size, size)

	return item


func update_powersource(x: int, y: int, tag: String, texture: String):
	var item = get_component(x, y)

	item._add_tag(tag)
	item._set_default_texture(texture)
	item._update_texture(texture)
	item.blocked_item = true


# Transforms the index into a 2d array index
func get_2d_index(index: int):
	var x = index % columns
	var y = index / columns

	return Vector2(x, y)


# Transforms the 2d array index into a 1d array index
func get_1d_index(x: int, y: int):
	return x + y * columns


func get_component(x: int, y: int):
	# If the index is out of bounds, return null
	if x < 0 or x >= columns or y < 0 or y >= columns:
		return null

	var index = get_1d_index(x, y)
	return get_child(index)
