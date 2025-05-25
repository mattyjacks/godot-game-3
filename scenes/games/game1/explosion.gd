extends GPUParticles3D

func _ready():
	# Set up explosion particles
	amount = 100
	lifetime = 2.0
	one_shot = true
	explosiveness = 0.9
	randomness = 0.2
	
	# Create material for explosion particles
	var particle_material = StandardMaterial3D.new()
	particle_material.albedo_color = Color(1.0, 0.5, 0.0)  # Orange fire color
	particle_material.emission_enabled = true
	particle_material.emission = Color(1.0, 0.3, 0.0)
	particle_material.emission_energy = 2.0
	
	# Set up particle mesh
	var particle_mesh = SphereMesh.new()
	particle_mesh.radius = 0.2
	particle_mesh.height = 0.4
	particle_mesh.material = particle_material
	
	# Configure particles
	draw_pass_1 = particle_mesh
	
	# Start emitting
	emitting = true
	
	# Remove after particles finish
	await get_tree().create_timer(lifetime + 0.5).timeout
	queue_free()
