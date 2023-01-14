extends Spatial

onready var mesh = $MeshInstance
onready var light = $SpotLight

var is_on = false

func _ready():
	pass
	

func _toggle():
	# Change the albedo of the mesh to amber
	var material = mesh.get_surface_material(0)
	if is_on:
		material.albedo_color = Color(0.21, 0.2, 0.18, 1)
		light.light_energy = 0.0
		is_on = false
	else:
		material.albedo_color = Color(1, 0.8, 0.16, 1)
		light.light_energy = 1.0
		is_on = true
	mesh.set_surface_material(0, material)
