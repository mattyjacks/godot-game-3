extends Node3D

# Cloud parameters
var rotation_speed = 0.05
var initial_rotation = 0.0

func _ready():
	# The cloud material is already set in the scene
	# Just randomize cloud parts slightly
	for part in $CloudParts.get_children():
		part.scale = Vector3.ONE * randf_range(0.8, 1.2)
	
	# Randomize initial rotation
	initial_rotation = randf_range(0, PI * 2)
	rotation.y = initial_rotation
	
	# Randomize cloud parts slightly
	for part in $CloudParts.get_children():
		part.scale = Vector3.ONE * randf_range(0.8, 1.2)
		part.position.y += randf_range(-0.2, 0.2)

func _process(delta):
	# Slowly rotate the cloud
	rotation.y += rotation_speed * delta
