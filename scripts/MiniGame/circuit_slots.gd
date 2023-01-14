extends TextureRect


export(bool) var blocked_item: bool = false  # determens if items are allowed to be placed here
export(bool) var infinate_sink: bool = false # Determeins if items draged out are coppied or moved. 
export(String) var pannel_name: String = ""

var puzzle: Control = null
onready var blank_texture: Texture = texture
var item_tags = [] # a empty array is used for empty slots
# neighbor pointers are update after creation
# they are left at null if no neighbor exists at that direction

var neighbor_up: Node = null
var neighbor_down: Node = null
var neighbor_left: Node = null
var neighbor_right: Node = null

# This is to keep track if the mouse is hovering over this tile
# If it is only then is some code exectued. 
var MouseOver = false


# Called when the node enters the scene tree for the first time.
func _ready():
	puzzle = get_tree().get_root().find_node("Puzzle", true, false)

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
	
func _set_default_texture(new_texture):
	if typeof(new_texture) == TYPE_STRING:
		blank_texture = load(new_texture)
	else:
			blank_texture = new_texture
	_update_texture(new_texture)

func _get_texture():
	return texture
	

func get_drag_data(_pos):
	# Retrieve information about the slot we are dragging from
	# Activated when the draggin starts
	if puzzle.edit_mode and not item_tags.empty():
		
		# the dict data is the information passed to the node when we drag it on to them
		var data = {}
		data["origin_node"] = self
		data["origin_panel"] = self.pannel_name
		data["item_tags"] = self.item_tags
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
		data["origin_node"].item_tags = self.item_tags.duplicate()
		if self.infinate_sink == true:
			data["origin_node"]._Clear_tile()
			
		
	if self.infinate_sink == false:
		self.item_tags = data["item_tags"].duplicate()
		self._update_texture(data["origin_texture"]) 
	self.hint_tooltip = str(item_tags)

func _neighbors():
	return [neighbor_up,neighbor_down , neighbor_left, neighbor_right]

func _set_neighbor(direction, neighbor):
	if direction == "up":
		neighbor_up = neighbor
	elif direction == "down":
		neighbor_down = neighbor
	elif direction == "left":
		neighbor_left = neighbor
	elif direction == "right":
		neighbor_right = neighbor
	else:
		print("ERROR: Invalid direction in _set_neighbor")
	
	
func _add_tag(item):
	if typeof(item) == TYPE_STRING:
		if not item_tags.has(item):
			item_tags.append(item)

	elif typeof(item) == TYPE_ARRAY:
		for i in item:
			if not item_tags.has(i):
				item_tags.append(i)

	self.hint_tooltip = str(item_tags)

	
func _remove_tag(item):
	if typeof(item) == TYPE_STRING:
		
		if item_tags.has(item):
			item_tags.erase(item)
	elif typeof(item) == TYPE_ARRAY:
		for i in item:
			if item_tags.has(i):
				item_tags.erase (i)
	self.hint_tooltip = str(item_tags)
	
func _has_tag(item):
	if typeof(item) == TYPE_STRING:
		if item_tags.has(item):
			return true
	elif typeof(item) == TYPE_ARRAY:
		for i in item:
			if not item_tags.has(i):
				return false
		return true
	else:
		return false
		
func _clear_tags():
	item_tags = []
	self.hint_tooltip = ""
	


# func _gui_input(event):
# 	# Only consider these keyboard interactions if they tile is hovering over the tile
# 	#if MouseOver == true:
# 	var edit_mode = puzzle.edit_mode
# 	if pannel_name == "Circuit" and event is InputEventMouseButton:
# 		if edit_mode:
# 			#MAKE WIRE
# 			pass
# 		else: #Input.is_action_pressed("interact") and not edit_mode : # (Either E or a mouse click)
# 			# flip the switch state
# 			if self._has_tag(["Switch", "open"]):
# 				self._remove_tag("open")
# 				self._add_tag("closed")
# 			elif self._has_tag(["Switch", "closed"]):
# 				self._remove_tag("closed")
# 				self._add_tag("open")
			
# #	if Input.is_action_pressed("interact") or Input.is_action_pressed("forward") and edit_mode : 
# #		if self.item_tags == []: # The tile has no tags
# #			pass #updat the 
# #	if Input.is_action_pressed("rotate") and edit_mode: 
# #		pass # for now
	


	

	
	
