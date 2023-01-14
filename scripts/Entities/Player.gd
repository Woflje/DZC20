extends KinematicBody

# STATIC VARIABLES
# How fast the player moves in meters per second.
export var speed: float = 14
# The downward acceleration when in the air, in meters per second squared.
export var fall_acceleration: float = 75

export var jump_impulse: float = 20
# there is no max fall speed at this point in time

# Camara variables look
var minLookAngle: float = -90.0
var maxLookAngle: float = 90.0
export var lookSensitivity: float = 10.0
onready var camera: Camera = get_node("Camera")
onready var raycast = $"Camera/RayCast"

onready var step_interval = 0
onready var step_interval_ticks = 20
onready var audio_step_files = []

# Global variables
var mouseDelta: Vector2 = Vector2()
var velocity = Vector3.ZERO

# Interactable variables
var last_interactable: Node = null


func _ready():
	audio_step_files.append(preload("res://assets/Audio/sfx/step_1.wav"))
	audio_step_files.append(preload("res://assets/Audio/sfx/step_2.wav"))
	audio_step_files.append(preload("res://assets/Audio/sfx/step_3.wav"))
	audio_step_files.append(preload("res://assets/Audio/sfx/step_4.wav"))
	

func _input(event):
	if event is InputEventMouseMotion:
		mouseDelta = event.relative

	if event.is_action_released("interact"):
		if raycast.is_colliding():
			var collider = raycast.get_collider()
			var interactable = collider.get_node("Interactable")
			if interactable != null:
				interactable._interact()


func _physics_process(delta):
	# The player movement is done by creating a vector, storing the direction the keys are pressed, and normalizing its direction.
	# Two oposite keys cancel each other and going sideways only generates a single velocity.

	var direction = Vector3.ZERO

	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_back"):
		direction.z += 1
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1
	if is_on_floor() and Input.is_action_pressed("jump"):
		velocity.y += jump_impulse

	if direction != Vector3.ZERO:
		direction = direction.normalized()
		$Pivot.look_at(translation + direction, Vector3.UP)

	# Direction is replacement this gives direct stoping
	# jumping is addative to keep momentum
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	
	if step_interval > step_interval_ticks and (velocity.z != 0 or velocity.x != 0) and is_on_floor():
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		$AudioStreamPlayer.stream = audio_step_files[rng.randi_range(0,3)]
		$AudioStreamPlayer.play()
		step_interval = 0
	else:
		step_interval += 1
	
	velocity.y -= fall_acceleration * delta
	# Rotate the axis so that forward is relative to the look direaction
	velocity = velocity.rotated(Vector3(0, 1, 0), camera.rotation.y)
	#No clue what this bottom line does.
	velocity = move_and_slide(velocity, Vector3.UP)

	# When hovering over an interactable object, show the interact popup
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		var interactable = collider.get_node("Interactable")
		print("WORKING")
		# When hovering over a new interactable object, stop hovering over the last one
		if interactable != null && interactable != last_interactable:
			if last_interactable != null:
				last_interactable._end_hover()
			interactable._start_hover()
			last_interactable = interactable
		# When hovering over nothing, stop hovering over the last interactable object
		elif interactable == null && last_interactable != null:
			last_interactable._end_hover()
			last_interactable = null
	# When not hovering over anything, stop hovering over the last interactable object
	elif last_interactable != null:
		last_interactable._end_hover()
		last_interactable = null



func _process(delta):
	camera.rotation_degrees.y -= mouseDelta.x * lookSensitivity * delta
	camera.rotation_degrees.x -= mouseDelta.y * lookSensitivity * delta
	# clamp camera x rotation axis
	# This prevents the camara moving to, (aka over the head or under the foot of the player
	camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, minLookAngle, maxLookAngle)

	# reset the mouseDelta vector, so that next frame delta isn't mudied by previous delta
	mouseDelta = Vector2()
