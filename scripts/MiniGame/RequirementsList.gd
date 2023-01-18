extends VBoxContainer

onready var puzzle = get_tree().get_root().find_node("Puzzle", true, false)
onready var requirement = preload("res://scenes/Requirement.tscn")
var ready = false
func _ready():
	ready = true
	_update_validators()
	

func _on_validators_updated():
	if ready:
		_update_validators()


func _on_toggle_simulation(_is_simulating: bool):
	if ready:
		_update_validators()

func _update_validators():
	_remove_children()
	var validators = puzzle.validators
	var edit_mode = puzzle.edit_mode

	for validator in validators:
		if edit_mode and validator.is_hidden:
			continue
		if validator.is_hidden and validator.has_completed:
			continue
			
		var req = requirement.instance()
		req.text = validator.get_label(not edit_mode)
		req.has_completed = validator.has_completed
		req.is_simulating = not edit_mode
		add_child(req)


func _remove_children():
	for child in get_children():
		remove_child(child)
		child.queue_free()
