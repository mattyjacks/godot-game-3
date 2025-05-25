extends Node3D

# Cloud parameters
var rotation_speed = 0.05
var initial_rotation = 0.0

func _ready():
	# Set up cloud appearance
	var cloud_mat = StandardMaterial3D.new()
	cloud_mat.albedo_color = Color(1.0, 1.0, 1.0, 0.8)  # White fluffy clouds
	cloud_mat.flags_transparent = true
	cloud_mat.roughness = 1.0
	
	# Apply material to all cloud parts
	for part in $CloudParts.get_children():
		part.material_override = cloud_mat
	
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
