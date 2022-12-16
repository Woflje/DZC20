extends TextureButton


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
	var data = {}
	
	var drag_texture = TextureRect.new()
	drag_texture.expand = true
	drag_texture.texture = texture
	drag_texture.rect_size = Vector2(100, 100)
	
	var control = Control.new()
	control.add_child(drag_texture)
	drag_texture.rect_position = -0.5 * drag_texture.rect_size
	set_drag_preview(control)
	
	return data
	
	
func can_drop_data(position, data):
	# Check if we can  drop an item in this slot
	
	
func drop_data(position, data):
	#What happens when we drop an item in this slot
	pass
	
