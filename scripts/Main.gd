extends Node

var intro_bool = true
var outro_bool = false
var intro_scene = preload("res://scenes/Intro.tscn").instance()
var overworld = preload("res://scenes/Overworld.tscn").instance()
var last_id_enterd = null

# we can make the puzzle a array of puzzle that are instaned with a specific puzzle in them.
# enviorment contains the hard references to each object on wich the _toggle should be called.
# Until we have a way to load in a specific puzzle just duplicate the puzzles
var blank_puzzle_1 = preload("res://scenes/Puzzle.tscn").instance()
var blank_puzzle_2 = preload("res://scenes/Puzzle.tscn").instance()
var blank_puzzle_3 = preload("res://scenes/Puzzle.tscn").instance()
var blank_puzzle_4 = preload("res://scenes/Puzzle.tscn").instance()

onready var puzzles = [blank_puzzle_1, blank_puzzle_2, blank_puzzle_3]
onready var groupe_enable = ["./Overworld/ToggleGroups/Group1", "./Overworld/ToggleGroups/Group2", "./Overworld/ToggleGroups/Group3"]
onready var groupe_enable_2 = ["./Overworld/ToggleGroups/Group1_only", "./Overworld/ToggleGroups/Group2_only", "./Overworld/ToggleGroups/Group3_only"]
onready var groupe_disable = ["./Overworld/ToggleGroups/Group0_only", "./Overworld/ToggleGroups/Group1_only", "./Overworld/ToggleGroups/Group2_only"]


# Called when the node enters the scene tree for the first time.
func _ready():
	blank_puzzle_1.include_validators(["at_least_one_lamp_present", "at_most_one_lamp_present", "lamps_are_off", "lamps_are_on"])
	blank_puzzle_2.include_validators(["at_least_one_led_present", "at_most_one_led_present", "led_is_in_safe_circuit"])
	blank_puzzle_3.include_validators([ "at_least_one_led_present", "at_most_one_led_present",  "	led_is_in_safe_circuit", "at_least_two_breaker_switcheds", "at_most_two_breaker_switcheds", "all_breakers_in_the_same_circuit", "pressing_either_breaker_changes_condition"])
	blank_puzzle_1.help_text_nom = "You can left click on a empty tile to create a wire"
	blank_puzzle_2.help_text_nom = "SECOND HINT NOR"
	blank_puzzle_3.help_text_nom = "A hotel switch is a type of circuit that changes the light on / off regadles of what switch (breaker) is pushed"
	blank_puzzle_1.help_text_sim = "Left click on a switch to change it state"
	blank_puzzle_2.help_text_sim = "SECOND HINT SIM "
	blank_puzzle_3.help_text_sim = "THIRD HINT SIM"
	self.add_child(intro_scene)
	
		

func _input(_event):
	# quit the game with a single key press
	# from any non frozen state
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()
	if Input.is_action_pressed("jump") and intro_bool == true:
		intro_bool = false
		self.remove_child(self.get_node("Intro"))
		_load_overworld(false, false)
		for each in groupe_enable:
			self.get_node(each).visible  = false
		for each in groupe_enable_2:
			self.get_node(each).visible  = false
		self.get_node("./Overworld/ToggleGroups/Group0_only").visible = true

func _load_overworld(unload = true, toggle = false):
	# Swithc to captued mouse mode and load in the overworld
	# Unload the puzzle by default unles it is defined that it should happen
	# like on the first load when it would crash
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	self.add_child(overworld)
	if unload:
		self.remove_child(self.get_node("Puzzle"))
	if toggle:  #
		self.get_node("./BGM").next_bgm = true
		self.get_node(groupe_enable[last_id_enterd]).visible  = true
		self.get_node(groupe_enable_2[last_id_enterd]).visible  = true
		self.get_node(groupe_disable[last_id_enterd]).get_parent().remove_child(self.get_node(groupe_disable[last_id_enterd]))

func _load_level(id):
	# switch to "Normal" mouse mode
	# unload the overworld
	# load the index of the puzle
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	last_id_enterd = id
	self.remove_child(self.get_node("Overworld"))
	self.add_child(puzzles[id])

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
