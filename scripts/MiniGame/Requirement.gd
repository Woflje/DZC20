extends MarginContainer

onready var icon = $"HBoxContainer/TextureRect"
onready var label = $"HBoxContainer/VBoxContainer/RichTextLabel"

onready var cross_icon = preload("res://assets/Textures/Overlay_components/cross.png")
onready var check_icon = preload("res://assets/Textures/Overlay_components/check.png")
onready var question_icon = preload("res://assets/Textures/Overlay_components/questionmark.png")

var text = ""
var has_completed:bool = false
var is_simulating:bool = false

func _ready():
	label.bbcode_text = "[color=%s]%s[/color]" % ["#628A8F" if has_completed else "#1E3F43", text]
	if has_completed:
		icon.texture = check_icon
	elif not is_simulating:
		icon.texture = question_icon #TODO REPLACE WITH QUESTION MARK ICON
	else:
		icon.texture = cross_icon
	
