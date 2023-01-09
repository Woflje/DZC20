extends StaticBody

signal interact


func _interact():
	emit_signal("interact")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene("res://scenes/drag_drop.tscn")
