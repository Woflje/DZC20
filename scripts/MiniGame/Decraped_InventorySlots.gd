extends TextureRect
onready var InventoryData: Node = get_node("../../../Inventory")
onready var CircuitData: Node = get_node("../../../Circuit")



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
		data["origin_item"] = InventoryData.inv_data[inv_slot]
		data["origin_texture"] = get_children()[0].texture

		var drag_texture = TextureRect.new()
		drag_texture.expand = true
		drag_texture.texture = get_children()[0].texture
		drag_texture.rect_size = Vector2(100, 100)

		var control = Control.new()
		control.add_child(drag_texture)
		drag_texture.rect_position = -0.5 * drag_texture.rect_size
		set_drag_preview(control)

		return data
	
	
func can_drop_data(_pos, data):
	# Check if we can drop an item in this slot
	return true
	# Whatever you are dragging you are allowed to drop in in the inventory
	


func drop_data(_pos, data):
	#What happens when we drop an item in this slot
	if data["origin_panel"] == "CircuitSheet":
			#remove the original
			data["origin_node"]._Clear_tile()
			

	return true
