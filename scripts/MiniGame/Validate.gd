extends Node

# reference aren't top down so I can debug puzzle without opening the game
onready var puzzle = get_node("./../..")
var grid:Dictionary = {}
var inventory:Dictionary = {}



func _on_PlaceHolder_pressed():
	# Switch Modes
	# if after the switch in edeting mode clean up the simulation
	# if not in edting mode start the simulation
	puzzle.edit_mode = !puzzle.edit_mode
	if puzzle.edit_mode:
		# clean up the simulation tags from each of the node ids
		for node in grid.values():
			node._remove_tag(["powerd", "shorted"])
	else:
		start_sim()
	
	update_tile_colours()

func start_sim():
	grid = get_node("./../Circuit").component_data
	inventory = get_node("./../Inventory").component_data
	for node in grid.values():
		if node._has_tag("power_scource_pos"):
			flow_energie(grid, node, ["powerd", "shorted"])
	if requirements_cheking([0,1], {}):
		get_node("./../Complete_Level").disabled = false

func flow_energie(grid:Dictionary, start_node:TextureRect, propogate:Array):
	start_node._add_tag(propogate)
	for node in start_node._neighbors():
		if node != null:
			if node._has_tag("wire") and not node._has_tag(propogate):
				flow_energie(grid, node, propogate)
			elif node._has_tag("power_scource_neg"):
				node._add_tag(propogate)
			elif node._has_tag("LED") and not node._has_tag("powerd"):
				flow_energie(grid, node, ["powerd"])
				

func update_tile_colours():
	if puzzle.edit_mode:
		for node in grid.values():
			node.modulate = Color(1, 1, 1) # WHITE
		for node in inventory.values():
			node.modulate = Color(1, 1, 1) # WHITE
	elif not puzzle.edit_mode: #
		for node in grid.values():
			if node._has_tag(["powerd", "shorted"]):
				node.modulate = Color(1, 0, 0) # RED
			elif node._has_tag("powerd"):
				node.modulate = Color(1, 1, 0) # Yellow
		for node in inventory.values():
			node.modulate = Color8(169,169,169) # GREY


func requirements_cheking(id_to_check:Array, info:Dictionary):
	#Given a interget array, go trough each of them 
	#Match them to their given functions
	#If all requirments pass this this function returns true
	var dispactch_table = {
	0: funcref(self, "neg_powerd_not_shorted"),
	1: funcref(self, "a_led_is_powerd"),
	}
	
	for id in id_to_check:
		if not dispactch_table[id].call_func(info):
			return false
	return true
		
					

func neg_powerd_not_shorted(info:Dictionary):
	for node in grid.values():
		if node._has_tag(["power_scource_neg","powerd"]):
			if node._has_tag("shorted"):
				return false
			return true
	
func a_led_is_powerd(info:Dictionary):
	for node in grid.values():
		if node._has_tag(["LED","powerd"]):
			return true
	return false
	
func led_unpowerd_with_switch_change(info:Dictionary):
	for node in grid.values():
		return true
		
	
	

