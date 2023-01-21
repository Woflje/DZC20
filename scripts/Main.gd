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
onready var groupe_enable = [
	"./Overworld/ToggleGroups/Group1",
	"./Overworld/ToggleGroups/Group2",
	"./Overworld/ToggleGroups/Group3"
]
onready var groupe_enable_2 = [
	"./Overworld/ToggleGroups/Group1_only",
	"./Overworld/ToggleGroups/Group2_only",
	"./Overworld/ToggleGroups/Group3_only"
]
onready var groupe_disable = [
	"./Overworld/ToggleGroups/Group0_only",
	"./Overworld/ToggleGroups/Group1_only",
	"./Overworld/ToggleGroups/Group2_only"
]


# Called when the node enters the scene tree for the first time.
func _ready():
	blank_puzzle_1.include_validators(
		["at_least_one_lamp_present", "at_most_one_lamp_present", "lamps_are_off", "lamps_are_on"]
	)
	blank_puzzle_2.include_validators(
		[
			"at_least_one_led_present",
			"at_most_one_led_present",
			"led_is_on",
			"led_is_in_safe_circuit"
		]
	)
	blank_puzzle_3.include_validators(
		[
			"at_least_one_led_present",
			"at_most_one_led_present",
			"at_least_two_breaker_switcheds",
			"at_most_two_breaker_switcheds",
			"all_breakers_in_the_same_circuit",
			"pressing_either_breaker_changes_condition",
			"led_is_off",
			"led_is_on",
			"led_is_in_safe_circuit",
		]
	)
	blank_puzzle_1.help_text_nom = "TASK: Create a circuit that turns on a lamp with a switch. \nTIP: Click 'simulate' to see if the circuit is correct."
	blank_puzzle_2.help_text_nom = "TASK: Wire an LED to light up permanently. Make sure that it does not short circuit. \nTIP: You can left click on an empty tile to create a wire, and click on a wire to delete it."
	blank_puzzle_3.help_text_nom = "TASK: A hotel switch is a type of circuit that changes the light on / off regardless of what switch (breaker) is pushed."
	blank_puzzle_1.help_text_sim = "Left click on a switch to change its state."
	blank_puzzle_2.help_text_sim = "HINT: LEDs have little internal resistance, so you need another way to limit the current."
	blank_puzzle_3.help_text_sim = "HINT: Both breakers need to be able to turn the light on and off. Independently of each other."
	self.add_child(intro_scene)

func to_overworld():
	self.remove_child(self.get_node("Intro"))
	_load_overworld(false, false)
	for each in groupe_enable:
		self.get_node(each).visible = false
	for each in groupe_enable_2:
		self.get_node(each).visible = false
	self.get_node("./Overworld/ToggleGroups/Group0_only").visible = true
	self.get_node("Fadescreen").visible = false

func _input(_event):
	# quit the game with a single key press
	# from any non frozen state
	# if Input.is_action_pressed("ui_cancel"):
	# 	get_tree().quit()
	if Input.is_action_pressed("jump") and intro_bool == true:
		$Fadescreen.fade_to_black()
		intro_bool = false


func _load_overworld(unload = true, toggle = false):
	# Swithc to captued mouse mode and load in the overworld
	# Unload the puzzle by default unles it is defined that it should happen
	# like on the first load when it would crash
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	self.add_child(overworld)
	if unload:
		self.remove_child(self.get_node("Puzzle"))
	if toggle:  #
		$SFX_Channel1.play()
		self.get_node("./BGM").next_bgm = true
		self.get_node(groupe_enable[last_id_enterd]).visible = true
		for node in self.get_node(groupe_enable[last_id_enterd]).get_node("Audio").get_children():
			node.play()
		
		self.get_node(groupe_enable_2[last_id_enterd]).visible = true
		self.get_node(groupe_disable[last_id_enterd]).get_parent().remove_child(
			self.get_node(groupe_disable[last_id_enterd])
		)
		if last_id_enterd == 2:
			self.get_node("./Overworld/ToggleGroups/Group3/TestBlock_end/CollisionShape").disabled = false


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
