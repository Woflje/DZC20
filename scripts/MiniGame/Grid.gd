extends GridContainer

onready var template_scene = preload("res://scenes/item_slot.tscn")

var default_texture = "res://assets/Textures/Overlay_components/grid block_1.png";

func _ready():
	var h_seperation = get_constant("hseparation")
	var size = rect_size[0] / columns - h_seperation

	for i in  columns*columns:
		add_child(create_item(size))
	
	pass

func create_item(size: float):
	var item = template_scene.instance()

	item._set_default_texture(default_texture)
	
	item.rect_min_size = Vector2(size,size)

	return item
