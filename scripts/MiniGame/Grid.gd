extends GridContainer

onready var template_scene = preload("res://scenes/item_slot.tscn")

var default_texture = "res://assets/Textures/Overlay_components/grid block_2.png"


func _ready():
	var h_seperation = get_constant("hseparation")
	var size = rect_size[0] / columns - h_seperation

	for i in columns * columns:
		add_child(create_item(size))

	for i in columns * columns:
		pass_neighbours(i)

	# Make (0, 2) and (0, 5) the power source
	update_powersource(0, 2, "power_scource_pos", "res://assets/Textures/Overlay_components/+_powersupply.png")
	update_powersource(0, 5, "power_scource_neg", "res://assets/Textures/Overlay_components/-_powersupply.png")

	pass


func create_item(size: float):
	var item = template_scene.instance()

	item._set_default_texture(default_texture)
	item._panel_circuit()

	item.rect_min_size = Vector2(size, size)

	return item

func update_powersource(x: int, y: int, tag: String, texture: String):
	var index = get_1d_index(x, y)
	var item = get_child(index)

	item._add_tag(tag)
	item._set_default_texture(texture)
	item._update_texture(texture)
	item.blocked_item = true;


# Transforms the index into a 2d array index
func get_2d_index(index: int):
	var x = index % columns
	var y = index / columns

	return Vector2(x, y)


# Transforms the 2d array index into a 1d array index
func get_1d_index(x: int, y: int):
	return x + y * columns


# pass the 4 neighbours to the item. If the item is on the edge of the grid, don't pass a neighbour
func pass_neighbours(index: int):
	var item = get_child(index)
	var index_2d = get_2d_index(index)

	var left = index_2d.x - 1
	var right = index_2d.x + 1
	var up = index_2d.y - 1
	var down = index_2d.y + 1

	if left >= 0:
		item._set_neighbor("left", get_child(get_1d_index(left, index_2d.y)))
	if right < columns:
		item._set_neighbor("right", get_child(get_1d_index(right, index_2d.y)))
	if up >= 0:
		item._set_neighbor("up", get_child(get_1d_index(index_2d.x, up)))
	if down < columns:
		item._set_neighbor("down", get_child(get_1d_index(index_2d.x, down)))
