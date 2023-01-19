extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if self.visible:
		if !$AudioPlayer.playing:
			$AudioPlayer.play()
	else:
		if $AudioPlayer.playing:
			$AudioPlayer.stop()
