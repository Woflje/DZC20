extends TextureRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var label: String
var dropped_on_target: bool = false
#var CircuitData = get_node("../../../FixInteraction").get("component_data")

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("DRAGGABLE")
	pass

func get_drag_data(_pos):
	# Retrieve information about the slot we are dragging
	var equipment_slot = get_parent().get_name()
#	if CircuitData.component_data[equipment_slot] != null:
	var data = {}
#		data["origin_node"] = self
#		data["origin_panel"] = "CircuitSheet"
#		data["origin_item_id"] = CircuitData.component_data[equipment_slot]
#		data["origin_equipment_slot"] = equipment_slot
#		data["origin_texture"] = texture
	
	var drag_texture = TextureRect.new()
	drag_texture.expand = true
	drag_texture.texture = texture
	drag_texture.rect_size = Vector2(100, 100)
	
	var control = Control.new()
	control.add_child(drag_texture)
	drag_texture.rect_position = -0.5 * drag_texture.rect_size
	set_drag_preview(control)

	return data
	
	
#func can_drop_data(_pos, data):
#	# Check if we can drop an item in this slot
#	var target_equipment_slot = get_parent().get_name()
#	if target_equipment_slot == data["origin_equipment_slot"]:
#		if CircuitData.component_data[target_equipment_slot] == null:
#			data["target_item_id"] = null
#			data["target_texture"] = null
#		else:
#			data["target_item_id"] = CircuitData.component_data[target_equipment_slot]
#			data["target_texture"] = texture
#		return true
#	else:
#		return false
	
	
#func drop_data(_pos, data):
#	#What happens when we drop an item in this slot
#	var target_equipment_slot =get_parent().get_name()
#	var origin_slot = data["origin_node"].get_parent().get_name()
#
#	#Update the data of origin
#	if data["origin_panel"] == "Inventory":
#		CircuitData.inv_data[origin_slot]["Item"] = data["target_item_id"]
#	else: #Circuit Sheet
#		CircuitData.component_data[origin_slot] = data["target_item_id"]
#
#	#Update the texture of the origin
#	if data["origin_panel"] == "CircuitSheet" and data["target_item_id"] == null:
#		var default_texture = load("res://Assets/UI_Elements/" + origin_slot + "_default_icon.png")
#		data["origin_node"].texture = default_texture
#	else:
#		data["origin_node"].texture = data["target_texture"]
		
	#Update the texture and data of the target
#	CircuitData.component_data[target_equipment_slot] = data["origin_item_id"]
#	texture = data["origin_texture"]
	
	
	
	
	
	
	
