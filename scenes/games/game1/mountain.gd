extends Node3D

func _ready():
	# Set up mountain appearance
	var mountain_mat = StandardMaterial3D.new()
	
	# Randomize mountain color slightly (brownish/grayish)
	var base_color = Color(0.4, 0.35, 0.3)
	var color_variation = randf_range(-0.1, 0.1)
	mountain_mat.albedo_color = base_color + Color(color_variation, color_variation, color_variation)
	
	# Apply material to mountain
	$MountainMesh.material_override = mountain_mat
	
	# Randomize mountain size and rotation
	scale.x = randf_range(0.8, 1.2)
	scale.z = randf_range(0.8, 1.2)
	rotation.y = randf_range(0, PI * 2)
