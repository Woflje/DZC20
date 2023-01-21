extends Node

signal bgm_fade_out

func _input(_event):
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit() # quit the game with a single key press

func _on_TestBlock_end_bgm_fade_out():
	emit_signal("bgm_fade_out")
