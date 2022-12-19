extends Control

var inv_data = {}
export var grid_size = 4

var component_data = {"Slot1": null,
"Slot2": null,
"Slot3": null,
"Slot4": null,
"Slot5": null,
}

#func _ready():
#	var inv_data_file = File.new()
#	inv_data_file.open("user://inv_data_file.json", File.READ)
#	var inv_data_json = JSON.parse(inv_data_file.get_as_text())
#	inv_data_file.close()
#	inv_data = inv_data_json.result
