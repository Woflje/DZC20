extends Node

signal interact

onready var popup = $Popup

func _ready():
	popup.visible = false

func _interact():
	emit_signal("interact")

func _start_hover():
	popup.visible = true

func _end_hover():
	popup.visible = false
