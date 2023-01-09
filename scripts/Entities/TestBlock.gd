extends StaticBody

signal interact


func _interact():
	emit_signal("interact")
