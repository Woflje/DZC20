extends Button
export(bool) var completeLevel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
# Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_PlaceHolder_pressed():
	# get the root node and load the overworld
	get_node("../../../")._load_overworld(true, completeLevel)

	
