extends Control

export(String, "Inventory", "Circuit", "Validation") var pannel_name
export(int) var grid_size
export(int) var canvas_area
export(int) var outer_margin
export(int) var inner_margin

onready var component_data=[]
onready var template_scene = preload("res://scenes/item_slot.tscn")
onready var block_size = canvas_area/grid_size


func _ready():
	component_data.resize(grid_size)
	component_data.fill([])
	var iteration_x: int = 0
	var iteration_y: int = 0
	
	for row in component_data:
		row.resize(grid_size)
		row.fill(null)
		for item in row:
			item=template_scene.instance() # Create a copy of the slot node
			add_child_below_node(get_node("./"), item) # built in function
			update_block_visuals(item, iteration_x, iteration_y)
			update_block_information(item, pannel_name, iteration_x, iteration_y)
			iteration_y = iteration_y + 1
		iteration_x = iteration_x + 1
		iteration_y = 0

func update_block_visuals(node: Node, x:int, y:int):
	# Manange the placing of each of the blocks
	var top_left_x = outer_margin+block_size*x+inner_margin
	var top_left_y = outer_margin+block_size*y+inner_margin
	node.rect_position = Vector2(top_left_x, top_left_y)
	node.rect_size = Vector2(block_size-2*inner_margin, block_size-2*inner_margin)
	
func update_block_information(node: Node, pannel_name:String, x:int, y:int):
	# Put down the correct information in each node
	node.pannel_name = pannel_name
	if pannel_name =="Inventory" :
		node.infinate_sink = true
		if y == 1:
			node._update_texture("res://icon.png")
			node.item_pointer = "Icon"
		else:
			node.item_pointer = "Wire"
			node._update_texture("res://What-Do-Electrical-Wire-Colors-Mean.jpg")
		 
			
			


