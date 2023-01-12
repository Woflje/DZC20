extends Control

export(String, "Inventory", "Circuit", "Validation") var pannel_name
export(int) var grid_size
export(int) var canvas_area
export(int) var outer_margin
export(int) var inner_margin

onready var component_data=[]
onready var template_scene = preload("res://scenes/item_slot.tscn")
onready var block_size:float = canvas_area/grid_size
var id:  = 0

var inv_item_list = [
		["wire","res://assets/Textures/Overlay_components/wire.png"],
		["LED","res://assets/Textures/Overlay_components/LED.png"],
		["lamp","res://assets/Textures/Overlay_components/lamp.png"],
		["diode","res://assets/Textures/Overlay_components/diode.png"],
		["double_breaker_switch","res://assets/Textures/Overlay_components/double_breaker_switch.png"],
		["bjt_transistor_pnp","res://assets/Textures/Overlay_components/bjt_transistor_pnp.png"],
		["relay_full","res://assets/Textures/Overlay_components/relay_full.png"],
		["resistor","res://assets/Textures/Overlay_components/resistor.png"],
		["switch_open","res://assets/Textures/Overlay_components/switch_open.png"],
		["switch_closed","res://assets/Textures/Overlay_components/switch_closed.png"],
		["transformator","res://assets/Textures/Overlay_components/transformator.png"],
		["power_scource_pos","res://icon.png"],
		#["power_scource_neg","res://What-Do-Electrical-Wire-Colors-Mean.jpg"],
		]

func _ready():
	component_data.resize(grid_size)
	component_data.fill([])
	# Enumeration of the array can't be used as we need to store the information back in the array
	
	for x in grid_size: # Iteration over a int, makes it a enumerator automaticaly
		component_data[x].resize(grid_size)
		for y in grid_size:
			var item=template_scene.instance() # Create a copy of the slot node
			add_child_below_node(get_node("./"), item) # built in function
			update_block_visuals(item, x, y)
			update_block_information(item, pannel_name, x, y)
			update_neighbor_pointer(item, component_data, x, y)
			component_data[x][y] = item

func update_block_visuals(node: Node, x:int, y:int):
	# Manange the placing of each of the blocks
	var top_left_x = outer_margin+block_size*x+inner_margin
	var top_left_y = outer_margin+block_size*y+inner_margin
	node.rect_position = Vector2(top_left_x, top_left_y)
	node.rect_size = Vector2(block_size-2*inner_margin, block_size-2*inner_margin)
	
func update_block_information(node: Node, pannel_name:String, x:int, y:int):
	# Put down the correct information in each node
	# This is where loading in levels could / should take place

	
	node.pannel_name = pannel_name
	if pannel_name =="Inventory" and  id < inv_item_list.size() :
		node.infinate_sink = true
		node._set_default_texture("res://assets/Textures/Overlay_components/grid block_1.png")
		node.item_id = inv_item_list[id][0]
		node._update_texture(inv_item_list[id][1])
		id += 1
	elif pannel_name =="Inventory":
		node.infinate_sink = true
		node.item_id = null
		node._set_default_texture("res://assets/Textures/Overlay_components/grid block_1.png")
	else:
		node.infinate_sink = false
		node.item_id = null
		node._set_default_texture("res://assets/Textures/Overlay_components/grid block_1.png")
		
		 
func update_neighbor_pointer(node: Node, array:Array, x:int, y:int):
	if x != 0:
		node.neighbor_up = array[x-1][y]
		array[x-1][y].neighbor_down = node
	if y != 0:
		node.neighbor_left = array[x][y-1]
		array[x][y-1].neighbor_right = node
		
			


