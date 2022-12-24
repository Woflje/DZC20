extends TextureRect
onready var blank_texture: Texture = get_children()[0].texture

var item_pointer = null #null is used for empty slot
export var varialbe_item = true  # determens if item are allowed to be dropped in this slot by the player

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("DRAGGABLE")
	pass

func _Clear_tile():
	var item_pointer = null
	get_children()[0].texture = blank_texture

func _update_texture(new_texture):
	get_children()[0].texture = new_texture
	
func _get_texture():
	return get_children()[0].texture
	

func get_drag_data(_pos):
	# Retrieve information about the slot we are dragging
	# Activated when the draggin starts
	if item_pointer != null:
		
		# the dict data is the information passed to the node when we drag it on to them
		var data = {}
		data["origin_node"] = self
		data["origin_panel"] = "CircuitSheet"
		data["origin_item"] = item_pointer
		data["origin_texture"] = get_children()[0].texture
		
		# Information for the sprite when dragging
		var drag_texture = TextureRect.new()
		drag_texture.expand = true
		drag_texture.texture = get_children()[0].texture
		drag_texture.rect_size = Vector2(100, 100)
	
		# ???
		var control = Control.new()
		control.add_child(drag_texture)
		drag_texture.rect_position = -0.5 * drag_texture.rect_size
		set_drag_preview(control)

		return data
	
	
func can_drop_data(_pos, data):
	# Check if we can drop an item in this slot
	# if variable_item is set to false than no items can be droped here
	return varialbe_item
	
	
func drop_data(_pos, data):
	# What happens when we drop an item in this slot
	# If its part of the Cicruit sheet, Write info to previous slot
	# Else only overwrite new cell with intem information
	
	if data["origin_panel"] == "CircuitSheet":
		data["origin_node"]._update_texture(self._get_texture()) 
		data["origin_node"].item_pointer = item_pointer
		
	item_pointer = data["origin_item"]
	self._update_texture(data["origin_texture"]) 
	
	
	
	
	
	
	
	
