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
	component.simulate(self)


func reset_simulation(close: bool = false):
	for component in grid_components.values():
		component._reset(close)
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
	var positive_current: bool

	func _init(pos: Vector2, node: TextureRect):
		self.pos = pos
		self.node = node
		self.positive_current = false

	func simulate(puzzle: Puzzle):
		_update_self(puzzle)

		var directions = _get_possible_neighbour_directions()
		for direction in directions:
			var next_pos = puzzle.get_position_by_direction(pos, direction)
			var component = puzzle.create_component_if_new(next_pos)
			if component == null:  # Already exists, so no need to index it again
				continue

			# If a component can't connect from a direction, then it's not a valid neighbour
			if not component._can_connect_from(puzzle.opisite_direction(direction)):
				puzzle.remove_component(next_pos)  # Remove the component from the cache. So it can be re-indexed later
				continue

			_update_neighbour(component)
			component.simulate(puzzle)

	func _update_self(puzzle: Puzzle):
		node.hint_tooltip = "Positive current: %s" % positive_current

	func _update_neighbour(component: Component):
		if positive_current:  # Only propagate the current if it's positive
			component.positive_current = positive_current

	func _get_possible_neighbour_directions() -> Array:
		return [0, 1, 2, 3]

	func _can_connect_from(direction: int) -> bool:
		return _get_possible_neighbour_directions().find(direction) != -1

	func _reset(close: bool):
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

	func _get_possible_neighbour_directions() -> Array:
		return []


class Wire:
	extends Component

	func _init(pos: Vector2, node: TextureRect).(pos, node):
		pass

	func _update_self(puzzle: Puzzle):
		._update_self(puzzle)
		if positive_current:
			node.modulate = Color(0.41, 1, 0.69)
		else:
			node.modulate = Color(1, 0.41, 0.42)


class Lamp:
	extends Component

	func _init(pos: Vector2, node: TextureRect).(pos, node):
		pass

	func _update_self(puzzle: Puzzle):
		._update_self(puzzle)
		node.modulate = Color(0.98, 1, 0.41)

	func _update_neighbour(component: Component):
		._update_neighbour(component)
		component.positive_current = false

	func _get_possible_neighbour_directions() -> Array:
		return [2, 3]


class Switch:
	extends Component

	var is_open: bool

	func _init(pos: Vector2, node: TextureRect).(pos, node):
		self.is_open = !node._has_tag("closed")

	func _update_self(puzzle: Puzzle):
		._update_self(puzzle)
		if positive_current:
			node.modulate = Color(0.41, 1, 0.69)
		else:
			node.modulate = Color(1, 0.41, 0.42)

		if is_open:
			node.texture = load("res://assets/Textures/Overlay_components/switch_open.png")
		else:
			node.texture = load("res://assets/Textures/Overlay_components/switch_closed.png")

		node.connect("simulated_item_clicked", self, "_on_simulated_item_clicked", [puzzle])

	func _on_simulated_item_clicked(puzzle: Puzzle):
		if is_open:
			node._add_tag("closed")
		else:
			node._remove_tag("closed")
		puzzle.simulate_flow()

	func _get_possible_neighbour_directions() -> Array:
		if is_open:
			return [0]  # Only up
		return [2, 3]

	func _can_connect_from(direction: int) -> bool:
		return direction == 2 or direction == 3

	func _reset(close: bool):
		._reset(close)
		if close:
			node._remove_tag("closed")
		node.texture = load("res://assets/Textures/Overlay_components/switch_open.png")
		node.disconnect("simulated_item_clicked", self, "_on_simulated_item_clicked")
