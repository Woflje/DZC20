extends TextureRect

signal clicked() # Emitted when the button is clicked.


func _gui_input(event):
    if event is InputEventMouseButton and event.is_pressed() and event.button_index == BUTTON_LEFT:
        emit_signal("clicked")

