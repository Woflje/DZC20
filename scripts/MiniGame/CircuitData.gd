extends Control


export var grid_size:int = 4
var component_data=[]
var template_scene = preload("res://scenes/item_slot.tscn")


func _ready():
	#Create a empty array Filled with new scenes
	print(template_scene)
	component_data.resize(grid_size)
	component_data.fill([])
	var iteration_x = 0
	var iteration_y = 0
	for row in component_data:
		row.resize(grid_size)
		row.fill(null)
		for item in row:
			item=template_scene.instance()
			add_child_below_node(get_node("Panel/Slots"), item)
			item.rect_position = Vector2(110*iteration_x-250, 110*iteration_y-100)
			iteration_y = iteration_y + 1
		iteration_x = iteration_x + 1
		iteration_y = 0
	
			
			


