extends StaticBody

signal interact
export(int) var puzzle_to_load

func _interact():
	# emit_signal("interact")
	# get the root node and load a level
	get_node("/root/Main")._load_level(puzzle_to_load)

