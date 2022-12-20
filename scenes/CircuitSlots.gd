extends TextureRect
onready var CircuitData = get_node("../../../../Circuit")
onready var blue_rectangle = get_children()[0].texture
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var label: String
var dropped_on_target: bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("DRAGGABLE")
	pass

func _blue():
	get_children()[0].texture = blue_rectangle
	pass

func get_drag_data(_pos):
	# Retrieve information about the slot we are dragging
	var equipment_slot = get_name()
	print(CircuitData)
	print(CircuitData.component_data[equipment_slot])
	if CircuitData.component_data[equipment_slot] != null:
		var data = {}
		data["origin_node"] = self
		data["origin_panel"] = "CircuitSheet"
		data["origin_item_id"] = CircuitData.component_data[equipment_slot]
		data["origin_equipment_slot"] = equipment_slot
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
#	# Check if we can drop an item in this slot
	var target_equipment_slot = get_name()
	data["target_item_id"] = CircuitData.component_data[target_equipment_slot]
	data["target_texture"] = texture
	return true
	
	
func drop_data(_pos, data):
	#What happens when we drop an item in this slot
	print(data)
	var target_equipment_slot = get_name()
	
	if data["origin_panel"] == "CircuitSheet":
		#then switch
		data["origin_node"].get_children()[0].texture = get_children()[0].texture
		CircuitData.component_data[data["origin_equipment_slot"]] = CircuitData.component_data[get_name()]
	CircuitData.component_data[target_equipment_slot] = data["origin_item_id"]
	get_children()[0].texture = data["origin_texture"]
	
	
	
	
	
	
	
	
