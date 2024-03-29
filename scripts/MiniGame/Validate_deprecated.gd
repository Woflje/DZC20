extends Node

# reference aren't top down so I can debug puzzle without opening the game
onready var puzzle = get_tree().get_root().find_node("Puzzle", true, false)
onready var circuit_node = get_tree().get_root().find_node("Circuit", true, false)
onready var inventory_node =  get_tree().get_root().find_node("Inventory", true, false)
var grid:Dictionary = {}
var inventory:Dictionary = {}



func _on_PlaceHolder_pressed():
	# Switch Modes
	# if after the switch in edeting mode clean up the simulation
	# if not in edting mode start the simulation
	puzzle.edit_mode = !puzzle.edit_mode
	if puzzle.edit_mode:
		# clean up the simulation tags from each of the nodes
		for node in grid.values():
			node._remove_tag(["powerd", "shorted"])
	else:
		start_sim()
	update_tile_colours()

func start_sim():
	grid = circuit_node.component_data
	inventory = inventory_node.component_data
	for node in grid.values():
		if node._has_tag("power_scource_pos"):
			flow_energie(grid, node, ["powerd", "shorted"], ["powerd", "shorted"])
	if requirements_cheking([0,1], {}):
		get_tree().get_root().find_node("Complete_Level", true, false).disabled = false

func flow_energie(grid:Dictionary, start_node:TextureRect, update_self:Array, propogate:Array):
	start_node._add_tag(update_self)	
	
	var listings = [ #propogate is alreayd a list so should not be encased in brackets
	[["wire"],				propogate,			propogate,	propogate],
	[["power_scource_neg"],	["FRED"],			propogate,	propogate], #it doesn't like empty lists, so when needed give it a always true chek
	[["LED"],				["powerd"],			["powerd"],	["powerd"]],
	[["Lamp"],				["powerd"],			["powerd"],	["powerd"]],
	[["Switch"],			["open", "closed"],	["open"],	[]],  # if the switch doesn't have states give it a open state
	[["Switch", "closed"],	["open"], 			propogate, 	propogate], # if the switch is closed propogate the power state throug it
	]
	
	
	if propogate != []:
		for node in start_node._neighbors():
			if node != null:
				for quadruple in listings:
					var does = quadruple[0]
					var does_not =quadruple[1]
					var update_other =quadruple[2]
					var move_throug =quadruple[3]
					if node._has_tag(does) and not node._has_tag(does_not):
						flow_energie(grid, node, update_other, move_throug)



func update_tile_colours():
	if puzzle.edit_mode:
		for node in grid.values():
			node.modulate = Color(1, 1, 1) # WHITE
		for node in inventory.values():
			node.modulate = Color(1, 1, 1) # WHITE
	elif not puzzle.edit_mode: # aka puzle in sim mode
		for node in grid.values():
			if node._has_tag(["powerd", "shorted"]):
				node.modulate = Color(1, 0, 0) # RED
			elif node._has_tag("powerd"):
				node.modulate = Color(1, 1, 0) # Yellow
			if node._has_tag(["Switch", "open"]):
				node._update_texture("res://assets/Textures/Overlay_components/switch_open.png")
			elif node._has_tag(["Switch", "closed"]):
				node._update_texture("res://assets/Textures/Overlay_components/switch_closed.png")
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
		
	
	

