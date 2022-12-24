extends TextureRect
onready var blank_texture: Texture = texture

# The data slots of each object
var item_pointer = null #null is used for empty slot
export(bool) var blocked_item: bool = false  # determens if items are allowed to be placed here
export(bool) var infinate_sink: bool = false # Determeins if items draged out are coppied or moved. 

export(String) var pannel_name: String = ""


# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("DRAGGABLE")
	pass

func _Clear_tile():
	var item_pointer = null
	texture = blank_texture

func _update_texture(new_texture):
	# Change the current texture but accpets both strings and texutures as inputs
	if typeof(new_texture) == TYPE_STRING:
		texture = load(new_texture)
	else:
			texture = new_texture
	
func _get_texture():
	return texture
	

func get_drag_data(_pos):
	# Retrieve information about the slot we are dragging from
	# Activated when the draggin starts
	if item_pointer != null:
		
		# the dict data is the information passed to the node when we drag it on to them
		var data = {}
		data["origin_node"] = self
		data["origin_panel"] = self.pannel_name
		data["origin_item"] = self.item_pointer
		data["origin_texture"] = texture
		
		# Information for the sprite when dragging
		var drag_texture = TextureRect.new()
		drag_texture.expand = true
		drag_texture.texture = texture
		drag_texture.rect_size = Vector2(100, 100)
	
		# ???
		var control = Control.new()
		control.add_child(drag_texture)
		drag_texture.rect_position = -0.5 * drag_texture.rect_size
		set_drag_preview(control)

		return data
	
	
func can_drop_data(_pos, data):
	# Check if we can drop an item in this slot
	# You man only drop items here if it is not a blocked slot
	return not blocked_item 
	
	
func drop_data(_pos, data):
	# What happens when we drop an item in this slot
	# If its part of the Cicruit sheet, Write info to previous slot
	# Else only overwrite new cell with intem information
	
	if data["origin_node"].infinate_sink == false:
		data["origin_node"]._update_texture(self._get_texture()) 
		data["origin_node"].item_pointer = item_pointer
		if self.infinate_sink == true:
			data["origin_node"]._Clear_tile()
			
		
	if self.infinate_sink == false:
		item_pointer = data["origin_item"]
		self._update_texture(data["origin_texture"]) 
	
	
	
	
	
	
	
	
