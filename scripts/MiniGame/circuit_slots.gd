extends TextureRect

signal simulated_item_clicked

enum PanelType { Components, Circuit }

export(bool) var blocked_item: bool = false  # determens if items are allowed to be placed here
export(bool) var infinate_sink: bool = false  # Determeins if items draged out are coppied or moved.
var panel_type = PanelType.Components

var puzzle: Control = null
onready var blank_texture: Texture = texture
var item_tags = []  # a empty array is used for empty slots
# neighbor pointers are update after creation
# they are left at null if no neighbor exists at that direction

onready var sfx_c1 = $SFX/Channel1
onready var sfx_c2 = $SFX/Channel2
onready var sfx_dict = {}

func _panel_components():
	panel_type = PanelType.Components


func _panel_circuit():
	panel_type = PanelType.Circuit


func _add_tag(item):
	if typeof(item) == TYPE_STRING:
		if not item_tags.has(item):
			item_tags.append(item)

	elif typeof(item) == TYPE_ARRAY:
		for i in item:
			if not item_tags.has(i):
				item_tags.append(i)

	_update_tooltip()


func _remove_tag(item):
	if typeof(item) == TYPE_STRING:
		if item_tags.has(item):
			item_tags.erase(item)
	elif typeof(item) == TYPE_ARRAY:
		for i in item:
			if item_tags.has(i):
				item_tags.erase(i)
	_update_tooltip()


func _get_first_tag():
	if item_tags.empty():
		return null
	return item_tags[0]


func _has_tag(item):
	if typeof(item) == TYPE_STRING:
		if item_tags.has(item):
			return true
		return false
	elif typeof(item) == TYPE_ARRAY:
		for i in item:
			if not item_tags.has(i):
				return false
		return true
	else:
		return false


func _clear_tags():
	item_tags = []
	_update_tooltip()

func _update_tooltip():
	var first_tag = _get_first_tag()
	if first_tag == null:
		self.hint_tooltip = ""
	else:
		self.hint_tooltip = first_tag

# Called when the node enters the scene tree for the first time.
func _ready():
	puzzle = get_tree().get_root().find_node("Puzzle", true, false)
	add_to_group("DRAGGABLE")
	sfx_dict["drag"] = preload("res://assets/Audio/sfx/circuit_editor_drag.wav")
	sfx_dict["drop"] = preload("res://assets/Audio/sfx/circuit_editor_drop.wav")

func _clear_tile():
	texture = blank_texture
	_clear_tags()


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
	if blocked_item:
		return null
	# Retrieve information about the slot we are dragging from
	# Activated when the draggin starts
	if puzzle.edit_mode and not item_tags.empty():
		# the dict data is the information passed to the node when we drag it on to them
		var data = {}
		data["origin_node"] = self
		data["origin_panel"] = self.panel_type
		data["item_tags"] = self.item_tags
		data["origin_texture"] = texture

		# Information for the sprite when dragging
		var drag_texture = TextureRect.new()
		drag_texture.expand = true
		drag_texture.texture = texture
		drag_texture.rect_size = Vector2(100, 100)

		# Create a control to hold the sprite
		var control = Control.new()
		control.add_child(drag_texture)
		drag_texture.rect_position = -0.5 * drag_texture.rect_size
		set_drag_preview(control)
		sfx_c1.stream = sfx_dict["drag"]
		sfx_c1.play()
		return data


func can_drop_data(_pos, _data):
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
			data["origin_node"]._clear_tile()

	if self.infinate_sink == false:
		self.item_tags = data["item_tags"].duplicate()
		self._update_texture(data["origin_texture"])
	_update_tooltip()
	sfx_c1.stream = sfx_dict["drop"]
	sfx_c1.play()


func _gui_input(event):
	if panel_type != PanelType.Circuit:
		return
	if blocked_item:
		return
	var edit_mode = puzzle.edit_mode
	if edit_mode:
		handle_edit_mode_input(event)
	else:
		handle_simulation_mode_input(event)


func handle_edit_mode_input(event):
	# If the mouse clicks on this tile and the tile is empty then change it to a wire
	if event is InputEventMouseButton:
		if event.pressed:
			return
		# If the button doesnt have any tags then it is empty
		# We want to toggle between empty and wire
		if item_tags.empty():
			_add_tag("wire")
			_update_texture("res://assets/Textures/Overlay_components/wire.png")
			sfx_c1.stream = sfx_dict["drop"]
			sfx_c1.play()
		elif _has_tag("wire"):
			sfx_c2.stream = sfx_dict["drag"]
			sfx_c2.play()
			_clear_tile()


func handle_simulation_mode_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			return
		emit_signal("simulated_item_clicked")
