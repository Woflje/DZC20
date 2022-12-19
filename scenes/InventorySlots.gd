extends TextureRect
onready var InventoryData = get_node("../../../Inventory")
onready var CircuitData = get_node("../../../Circuit")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var label: String
var dropped_on_target: bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("DRAGGABLE")
	pass

func get_drag_data(_pos):
	# Retrieve information about the slot we are dragging
	var inv_slot = get_name()
	if InventoryData.inv_data[inv_slot] != null:
		var data = {}
		data["origin_node"] = self
		data["origin_panel"] = "Inventory"
		data["origin_item_id"] = InventoryData.inv_data[inv_slot]
		data["origin_texture"] = texture

		var drag_texture = TextureRect.new()
		drag_texture.expand = true
		drag_texture.texture = texture
		drag_texture.rect_size = Vector2(100, 100)

		var control = Control.new()
		control.add_child(drag_texture)
		drag_texture.rect_position = -0.5 * drag_texture.rect_size
		set_drag_preview(control)

		return data
	
	
func can_drop_data(_pos, data):
#	# Check if we can  drop an item in this slot
	var target_inv_slot = get_parent().get_name()
#	if CircuitData.inv_Data[target_inv_slot] == null: #We move an item
#		data["target_item_id"] = null
#		data["target_texture"] = null
#		return true
#	else: #We swap an item
#		data["target_item_id"] = CircuitData.inv_data[target_inv_slot]["Item"]
#		data["target_texture"] = texture
#		if data["origin_panel"] == "CharacterSheet":
#			var target_equipment_slot = InventoryData.item_data[str(CircuitData.inv_data[target_inv_slot]["Item"])]["EquipmentSlot"]
#			if target_equipment_slot == data["origin_equipment_slot"]:
#				return true
#			else:
	return false
#		else: #data["origin_panel"] == "Inventory":
#			return true
#
func drop_data(_pos, data):
#	#What happens when we drop an item in this slot
#	var target_inv_slot =get_parent().get_name()
#	var origin_slot = data["origin_node"].get_parent().get_name()
#
#	#Update the data of origin
#	if data["origin_panel"] == "Inventory":
#		PlayerData.inv_data[origin_slot]["Item"] = data["target_item_id"]
#	else: #CharacterSheet
#		PlayerData.equipment_data[origin_slot] = data["target_item_id"]
#
#	#Update the texture of the origin
#	if data["origin_panel"] == "CharacterSheet" and data["target_item_id"] == null:
#		var default_texture = load("res://Assets/UI_Elements/" + origin_slot + "_default_icon.png")
#		data["origin_node"].texture = default_texture
#	else:
#		data["origin_node"].texture = data["target_texture"]
#
#	#Update the texture and data of the target
#	PlayerData.inv_data[target_inv_slot] = data["origin_item_id"]
	pass
