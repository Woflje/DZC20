extends Node



func _on_PlaceHolder_pressed():
	pass
	# Turn on + battery
	# flow energie through wires
	var grid = get_node("./../Circuit").component_data
	print(grid)
	for row in grid:
		for node in row:
			print(node.item_id)
			if node.item_id == "power_scource_pos":
				print("FOUND BATTERY")
				flow_energie(grid, node)
			
func flow_energie(grid, start_cor):
	start_cor.powerd = true
	
	for each in start_cor._neighbors():
		if each != null and each.item_id == "wire" and each.powerd == false:
			each.modulate = Color(1, 0, 0)
			flow_energie(grid, each)
	
	
	

