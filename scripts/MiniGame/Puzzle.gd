extends Node

class_name Puzzle

signal toggle_simulation(is_simulating)
signal validators_updated()
signal puzzle_completed()

var edit_mode:bool = true

var grid_components = {}

var validators = [SafeCiruitValidator.new()]

onready var grid = get_tree().get_root().find_node("Grid", true, false)


func _ready():
	# Testing things
	var validator_ids = ["HasACompleteCircuitValidator"]
	include_validators(validator_ids)

func _input(_event):
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()  # quit the game with a single key press

func include_validators(validator_ids: Array):
	for validator_id in validator_ids:
		include_validator(validator_id)
	emit_signal("validators_updated")

func include_validator(validator_id: String):
	if validator_id == "safe_circuit":
		validators.append(SafeCiruitValidator.new())
	if validator_id == "at_least_one_lamp_present":
		validators.append(AtLeastOneLampPresentValidator.new())
	if validator_id == "HasACompleteCircuitValidator":
		validators.append(HasACompleteCircuitValidator.new())
		

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
	validate()

	
func discover_nodes(current: Component):
	var directions = current.get_possible_neighbour_directions()
	for direction in directions:
		var pos = get_position_by_direction(current.pos, direction)
		var component = create_component_if_new(pos)
		if component == null:
			continue
		if component.get_possible_neighbour_directions().find(opisite_direction(direction)) == -1:
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

func validate():
	for validator in validators:
		validator.update_completed(self)

	emit_signal("validators_updated")
	
	# If all validators are completed, we can complete the puzzle
	for validator in validators:
		if not validator.has_completed:
			return
	print("All validators completed")
	emit_signal("puzzle_completed")

func reset_simulation(close: bool = false):
	for component in grid_components.values():
		component.reset(close)
	grid_components.clear()
	if close:
		for validator in validators:
			validator.reset()


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
	if tag == "LED":
		return LED.new(pos, node)
	if tag == "diode":
		return Diode.new(pos, node)
	if tag == "resistor":
		return Resistor.new(pos, node)
	if tag == "breaker_right":
		return Double_Switch_R.new(pos, node)
	if tag == "breaker_left":
		return Double_Switch_L.new(pos, node)
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
		self.positive_current = false
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

class Resistor:
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
			
	func get_possible_neighbour_directions() -> Array:
		return [2, 3]

	func get_flow_directions() -> Array:
		return [2, 3]


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
		
class LED:
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
		
	func get_flow_directions() -> Array:
		return [3]

class Diode:
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

	func update_neighbour(component: Component):
		.update_neighbour(component)
		component.positive_current = false

	func get_possible_neighbour_directions() -> Array:
		return [2, 3]
		
	func get_flow_directions() -> Array:
		return [3]


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

		node.connect("simulated_item_clicked", self, "on_simulated_item_clicked", [puzzle])

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
		node.disconnect("simulated_item_clicked", self, "on_simulated_item_clicked")
		
class Double_Switch_L:
	extends Component

	var is_down: bool

	func _init(pos: Vector2, node: TextureRect).(pos, node):
		self.is_down = node._has_tag("is_down")

	func update_self(puzzle: Puzzle):
		.update_self(puzzle)
		if not powered:
			node.modulate = Color(0.51,0.51,0.51)
		elif positive_current:
			node.modulate = Color(0.41, 1, 0.69)
		else:
			node.modulate = Color(1, 0.41, 0.42)
		
		if is_down:
			node.texture = load("res://assets/Textures/Overlay_components/double_breaker_switch_left_flipped.png")
		else:
			node.texture = load("res://assets/Textures/Overlay_components/double_breaker_switch_left.png")

		node.connect("simulated_item_clicked", self, "on_simulated_item_clicked", [puzzle])

	func on_simulated_item_clicked(puzzle: Puzzle):
		if is_down:
			node._remove_tag("is_down")
		else:
			node._add_tag("is_down")
		puzzle.simulate_flow()

	func get_possible_neighbour_directions() -> Array:
		return [0, 2, 3]

	func get_flow_directions() -> Array:
		if is_down:
			return [0, 3]
		else:
			return [0, 2]	
		
	func can_connect_from(direction: int) -> bool:
		return direction in get_flow_directions()

	func reset(close: bool):
		.reset(close)
		if close:
			node._remove_tag("is_down")
		node.texture = load("res://assets/Textures/Overlay_components/double_breaker_switch_left.png")
		node.disconnect("simulated_item_clicked", self, "on_simulated_item_clicked")

class Double_Switch_R:
	extends Component

	var is_down: bool

	func _init(pos: Vector2, node: TextureRect).(pos, node):
		self.is_down = node._has_tag("is_down")

	func update_self(puzzle: Puzzle):
		.update_self(puzzle)
		if not powered:
			node.modulate = Color(0.51,0.51,0.51)
		elif positive_current:
			node.modulate = Color(0.41, 1, 0.69)
		else:
			node.modulate = Color(1, 0.41, 0.42)
		
		if is_down:
			node.texture = load("res://assets/Textures/Overlay_components/double_breaker_switch_right_flipped.png")
		else:
			node.texture = load("res://assets/Textures/Overlay_components/double_breaker_switch_right.png")

		node.connect("simulated_item_clicked", self, "on_simulated_item_clicked", [puzzle])

	func on_simulated_item_clicked(puzzle: Puzzle):
		if is_down:
			node._remove_tag("is_down")
		else:
			node._add_tag("is_down")
		puzzle.simulate_flow()

	func get_possible_neighbour_directions() -> Array:
		return [1, 2, 3]

	func get_flow_directions() -> Array:
		if is_down:
			return [1, 3]
		else:
			return [1, 2]
			
	func can_connect_from(direction: int) -> bool:
		return direction in get_flow_directions()

	func reset(close: bool):
		.reset(close)
		if close:
			node._remove_tag("is_down")
		node.texture = load("res://assets/Textures/Overlay_components/double_breaker_switch_right.png")
		node.disconnect("simulated_item_clicked", self, "on_simulated_item_clicked")



class Validator:
	var is_hidden: bool
	var has_completed: bool

	var display_text_achieved: String
	var display_text_failed: String
	var display_text_working_on_it:String

	func get_label(simulating):
		if has_completed:
			return display_text_achieved
		elif simulating:
			return display_text_failed
		else:
			return display_text_working_on_it

	func update_completed(puzzle: Puzzle):
		if not has_completed:
			has_completed = verify_completed(puzzle)

	func verify_completed(puzzle: Puzzle) -> bool:
		return false

	func reset():
		has_completed = false

class SafeCiruitValidator:
	extends Validator

	func _init(): 
		self.is_hidden = true
		# If it is hidden no completed messag is needed.
		self.display_text_failed = "This circuit has a short circuit"

	func verify_completed(puzzle: Puzzle) -> bool:
		# Check that the negative power source has a negative current
		var negative_power_source_pos = Vector2(0, 5)
		var negative_power_source = puzzle.get_component(negative_power_source_pos)
		if negative_power_source == null:
			return true
		return not negative_power_source.positive_current
	




class HasACompleteCircuitValidator:
	extends Validator

	func _init():
		self.is_hidden = true
		# If it is hidden no completed messag is needed.
		self.display_text_failed = "This circuit is not complete"
	
	func verify_completed(puzzle: Puzzle) -> bool:
		return true
	#TODO!
		
class AtLeastOneLampPresentValidator:
	extends Validator

	func _init():
		self.is_hidden = false
		self.display_text_achieved = "A lamp is included in the circuit"
		self.display_text_failed = "This circuit does not have any lamps"
		self.display_text_working_on_it = "One lamp is required in the circuit"

	func verify_completed(puzzle: Puzzle) -> bool:
		# Check that in the grid_components there is one component with type Lamp
		for component in puzzle.grid_components.values():
			if component is Lamp:
				return true
		return false
		
class AtMostOneLampPresentValidator:
	extends Validator

	func _init():
		self.is_hidden = true
		self.display_text_failed = "This circuit has to many any lamps"
	
	func verify_completed(puzzle: Puzzle) -> bool:
		var lamp_count: int = 0
		for component in puzzle.grid_components:
			if component is Lamp:
				lamp_count += 1
		
		if lamp_count > 1:
			return true
		else:
			return false

		
class LampsStartOfValidator:
	extends Validator

	func _init():
		self.is_hidden = true
		self.display_text_failed = "The Lamp Starts On"
	
	func verify_completed(puzzle: Puzzle) -> bool:
		
		for component in puzzle.grid_components:
			if component is Lamp:
				# TODO!
				#if component == on
					return false
		return true


class LampsHaveBeenTurnedOnValidator:
	extends Validator

	func _init():
		self.is_hidden = false
		self.display_text_achieved = "The lamp has been turned on"
		self.display_text_failed = "The lamp has not been turned on yet"
		self.display_text_working_on_it = "Lamps must be able to change state"

	# TODO!
class AtLeastOneLEDPresentValidator:
	extends Validator

	func _init():
		self.is_hidden = false
		self.display_text_achieved = "There is a LED present in the circuit"
		self.display_text_failed = "There are no LED present in the circuit"
		self.display_text_working_on_it = "The circuit requires one LED"

	func verify_completed(puzzle: Puzzle) -> bool:
		for component in puzzle.grid_components:
			if component is LED:
				return true
		return false

class AtMostOneLEDPresentValidator:
	extends Validator

	func _init():
		self.is_hidden = true
		#self.display_text_achieved = "There is a LED present in the circuit"
		self.display_text_failed = "There are too many LEDs present in the circuit"
		
	
	func verify_completed(puzzle: Puzzle) -> bool:
		var LED_count: int = 0
		for component in puzzle.grid_components:
			if component is LED:
				LED_count += 1
		
		if LED_count > 1:
			return false
		else:
			return true

class LedIsInSafeCircuitValidator:
	extends Validator

	func _init():
		self.is_hidden = false
		self.display_text_achieved = "The Circuit is safe"
		self.display_text_failed ="The Circuit is not safe (try adding a ristor before the LED)"
		self.display_text_working_on_it = "The Circuit needs to be safe"

	#TODO

class AtLeastTwoBreakerSwitchedsValidator:
	extends Validator

	func _init():
		self.is_hidden = false
		self.display_text_achieved = "Two breaker switches are present in the circuit"
		self.display_text_failed = "There are less than two breakers switches present in the circuit"
		self.display_text_working_on_it = "This circuit requires two breakers"
	
	func verify_completed(puzzle: Puzzle) -> bool:
		var breaker_count: int = 0
		for component in puzzle.grid_components:
			if (component is Double_Switch_L) or (component is Double_Switch_R):
				breaker_count += 1
		
		if breaker_count >= 2:
			return true
		else:
			return false
class AtMostTwoBreakerSwitchedsValidator:
	extends Validator

	func _init():
		self.is_hidden = true
		#self.display_text_achieved = "The Circuit is safe"
		self.display_text_failed = "There are to many Breakers switches present in the circuit"

	func verify_completed(puzzle: Puzzle) -> bool:
		var breaker_count: int = 0
		for component in puzzle.grid_components:
			if (component is Double_Switch_L) or (component is Double_Switch_R):
				breaker_count += 1
		
		if breaker_count > 2:
			return false
		else:
			return true


class AllBreakersInTheSameCircuitValidator:
	extends Validator

	func _init():
		self.is_hidden = true
		#self.display_text_achieved = "The Circuit is safe"
		self.display_text_failed = "The breaker switches are not part of the same circuit"

	#TODO

class PressingEitherBreakerChangesConditionValidator:
	extends Validator

	func _init():
		self.is_hidden = false
		self.display_text_achieved = "You have made a hotel Switch!"
		self.display_text_failed = "Press both breakers to proof that they effect the LED"
		self.display_text_working_on_it = "Each breaker must influance the LED"


	# TODO
