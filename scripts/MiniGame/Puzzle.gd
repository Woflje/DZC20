extends Node

class_name Puzzle

signal toggle_simulation(is_simulating)

var edit_mode = true

var grid_components = {}

onready var grid = get_tree().get_root().find_node("Grid", true, false)


func _input(_event):
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()  # quit the game with a single key press


func _toggle_simulate_mode():
	edit_mode = !edit_mode
	if edit_mode:
		reset_simulation(true)
	else:
		simulate_flow()
	emit_signal("toggle_simulation", !edit_mode)


func simulate_flow():
	reset_simulation()
	# We start the simulation by the positive power source
	var pos = Vector2(0, 2)
	var positive_source = grid.get_component(pos.x, pos.y)
	var component = PositivePowerSource.new(pos, positive_source)
	grid_components[serialize_position(pos)] = component
	discover_nodes(component)
	simulate_power([component.pos])
	update_components()

	
func discover_nodes(current: Component):
	var directions = current.get_possible_neighbour_directions()
	for direction in directions:
		var pos = get_position_by_direction(current.pos, direction)
		var component = create_component_if_new(pos)
		if component == null:
			continue
		if not component.can_connect_from(opisite_direction(direction)):
			continue
		current.update_neighbour(component)
		discover_nodes(component)


func simulate_power(path: Array = []):
	# Find all possible paths from the positive power source to the negative power source
	var current_pos = path[path.size() - 1]
	var current = get_component(current_pos)
	var directions = current.get_flow_directions()
	for direction in directions:
		var pos = get_position_by_direction(current.pos, direction)
		var component = get_component(pos)
		if component == null:
			continue
		if not component.can_connect_from(opisite_direction(direction)):
			continue
		if path.find(component.pos) != -1:
			continue
		var new_path = path.duplicate()
		new_path.append(component.pos)
		if component is NegativePowerSource:
			complete_path(new_path)
			continue
		simulate_power(new_path)
		
func complete_path(path: Array):
	for component_pos in path:
		var component = get_component(component_pos)
		component.powered = true


func update_components():
	for component in grid_components.values():
		component.update_self(self)


func reset_simulation(close: bool = false):
	for component in grid_components.values():
		component.reset(close)
	grid_components.clear()


# Serialized position
func serialize_position(vec: Vector2) -> String:
	return "%d,%d" % [vec.x, vec.y]


func get_component(pos: Vector2) -> Component:
	var serialized_pos = serialize_position(pos)
	if not serialized_pos in grid_components:
		return null
	return grid_components[serialize_position(pos)]


func store_component(component: Component):
	grid_components[serialize_position(component.pos)] = component


func remove_component(pos: Vector2):
	var serialized_pos = serialize_position(pos)
	if not serialized_pos in grid_components:
		return
	grid_components.erase(serialized_pos)


func create_component(pos: Vector2, node: TextureRect):
	var tag = node._get_first_tag()
	if tag == null:
		return null

	if tag == "power_source_pos":
		return PositivePowerSource.new(pos, node)
	if tag == "power_source_neg":
		return NegativePowerSource.new(pos, node)
	if tag == "wire":
		return Wire.new(pos, node)
	if tag == "lamp":
		return Lamp.new(pos, node)
	if tag == "switch":
		return Switch.new(pos, node)

	return null


# Create a component if it doesn't exist yet. Returns the component if it was created, null otherwise
func create_component_if_new(pos: Vector2):
	var component = get_component(pos)
	if component != null:
		return null
	var node = grid.get_component(pos.x, pos.y)
	if node == null:
		return null
	component = create_component(pos, node)
	if component == null:
		return null
	store_component(component)
	return component


func get_position_by_direction(pos: Vector2, direction: int) -> Vector2:
	match direction:
		0:  # Left
			return Vector2(pos.x - 1, pos.y)
		1:  # Right
			return Vector2(pos.x + 1, pos.y)
		2:  # Up
			return Vector2(pos.x, pos.y - 1)
		3:  # Down
			return Vector2(pos.x, pos.y + 1)
	return pos


func opisite_direction(direction: int) -> int:
	match direction:
		0:  # Left
			return 1  # Right
		1:  # Right
			return 0  # Left
		2:  # Up
			return 3  # Down
		3:  # Down
			return 2  # Up
	return direction


class Component:
	var pos: Vector2
	var node: TextureRect
	var positive_current: bool = false
	var powered: bool = false

	func _init(pos: Vector2, node: TextureRect):
		self.pos = pos
		self.node = node

	func update_self(_puzzle: Puzzle):
		node.hint_tooltip = "Powered: %s" % powered

	func update_neighbour(component: Component):
		if positive_current:  # Only propagate the current if it's positive
			component.positive_current = positive_current

	func get_possible_neighbour_directions() -> Array:
		return [0, 1, 2, 3]

	func get_flow_directions() -> Array:
		return get_possible_neighbour_directions()

	func can_connect_from(direction: int) -> bool:
		return get_possible_neighbour_directions().find(direction) != -1

	func reset(close: bool):
		node.hint_tooltip = str(node.item_tags)
		node.modulate = Color(1, 1, 1)


class PositivePowerSource:
	extends Component

	func _init(pos: Vector2, node: TextureRect).(pos, node):
		self.positive_current = true


class NegativePowerSource:
	extends Component

	func _init(pos: Vector2, node: TextureRect).(pos, node):
		pass

	func get_possible_neighbour_directions() -> Array:
		return []

	func get_flow_directions() -> Array:
		return [0, 1, 2, 3]

	func can_connect_from(direction: int) -> bool:
		return true

class Wire:
	extends Component

	func _init(pos: Vector2, node: TextureRect).(pos, node):
		pass

	func update_self(puzzle: Puzzle):
		.update_self(puzzle)
		if not powered:
			node.modulate = Color(0.51,0.51,0.51)
		elif positive_current:
			node.modulate = Color(0.41, 1, 0.69)
		else:
			node.modulate = Color(1, 0.41, 0.42)


class Lamp:
	extends Component

	func _init(pos: Vector2, node: TextureRect).(pos, node):
		pass

	func update_self(puzzle: Puzzle):
		.update_self(puzzle)
		if not powered:
			node.modulate = Color(0.51,0.51,0.51)
		else: 
			node.modulate = Color(0.98, 1, 0.41)

	func update_neighbour(component: Component):
		.update_neighbour(component)
		component.positive_current = false

	func get_possible_neighbour_directions() -> Array:
		return [2, 3]


class Switch:
	extends Component

	var is_open: bool

	func _init(pos: Vector2, node: TextureRect).(pos, node):
		self.is_open = !node._has_tag("closed")

	func update_self(puzzle: Puzzle):
		.update_self(puzzle)
		if not powered:
			node.modulate = Color(0.51,0.51,0.51)
		elif positive_current:
			node.modulate = Color(0.41, 1, 0.69)
		else:
			node.modulate = Color(1, 0.41, 0.42)

		if is_open:
			node.texture = load("res://assets/Textures/Overlay_components/switch_open.png")
		else:
			node.texture = load("res://assets/Textures/Overlay_components/switch_closed.png")

		node.connect("simulated_item_clicked", self, "_on_simulated_item_clicked", [puzzle])

	func on_simulated_item_clicked(puzzle: Puzzle):
		if is_open:
			node._add_tag("closed")
		else:
			node._remove_tag("closed")
		puzzle.simulate_flow()

	func get_possible_neighbour_directions() -> Array:
		return [2, 3]

	func get_flow_directions() -> Array:
		if is_open:
			return []
		return get_possible_neighbour_directions()

	func reset(close: bool):
		.reset(close)
		if close:
			node._remove_tag("closed")
		node.texture = load("res://assets/Textures/Overlay_components/switch_open.png")
		node.disconnect("simulated_item_clicked", self, "_on_simulated_item_clicked")
