extends Control


var inv_data = {"Wire": 1}

#var inv_data_file = File.new()
#inv_data_file.open("user://inv_data_file.json", File.READ)
#var inv_data_json = JSON.parse(inv_data_file.get_as_text())
#inv_data_file.close()
#inv_data = inv_data_json.result


#extends Control
#
#var inv_data = {}
#export var grid_size = 4
#
#var component_data = []
#
#func _ready( ):
#	component_data.resize(grid_size)
#
#	for item in component_data:
#		item = []
#		item.resize(grid_size)
#
#	var inv_data_file = File.new()
#	inv_data_file.open("user://inv_data_file.json", File.READ)
#	var inv_data_json = JSON.parse(inv_data_file.get_as_text())
#	inv_data_file.close()
#	inv_data = inv_data_json.result
