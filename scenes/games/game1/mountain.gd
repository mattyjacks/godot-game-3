extends Node3D

func _ready():
	# The material is already set in the scene file
	# Just randomize mountain rotation and position slightly
	
	# Randomize mountain size and rotation
	scale.x = randf_range(0.8, 1.2)
	scale.z = randf_range(0.8, 1.2)
	rotation.y = randf_range(0, PI * 2)
	
	# Randomize sub-mountains slightly
	for child in get_children():
		if child.name.begins_with("MountainMesh") and child != $MountainMesh:
			child.rotation.y = randf_range(0, PI * 2)
			child.position.x += randf_range(-2, 2)
			child.position.z += randf_range(-2, 2)
