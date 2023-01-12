extends Node

var overworld = preload("res://scenes/Overworld.tscn").instance()
var last_id_enterd = null

# we can make the puzzle a array of puzzle that are instaned with a specific puzzle in them.
# enviorment contains the hard references to each object on wich the _toggle should be called. 
# Until we have a way to load in a specific puzzle just duplicate the puzzles

var puzzles= [preload("res://scenes/drag_drop.tscn").instance()]
var enviorment = ["./Overworld/Lamp"]

# Called when the node enters the scene tree for the first time.
func _ready():
	_load_overworld(false, false)
	
	
func _input(event):
	# quit the game with a single key press
	# from any non frozen state
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit() 

func _load_overworld(unload=true, toggle=false):
	# Swithc to captued mouse mode and load in the overworld
	# Unload the puzzle by default unles it is defined that it should happen
	# like on the first load when it would crash
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	self.add_child(overworld)
	if unload:
		self.remove_child(self.get_node("Puzzle"))
	if toggle: #
		self.get_node(enviorment[last_id_enterd])._toggle()
		
	

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
