extends StaticBody

signal interact

func _interact():
	get_tree().root.get_node("./Main/BGM").fadeout = true
	$Fadescreenend.fade_to_black()

func _quit_game():
	get_tree().quit()
