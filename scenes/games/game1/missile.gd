extends Area3D

# Missile properties
var speed = 50.0
var damage = 100
var target = null
var max_lifetime = 5.0
var current_lifetime = 0.0

# Tracking properties
var tracking_strength = 5.0

func _ready():
	# Material is already set in the scene
	
	# Set up missile trail particles
	var particles = $MissileTrail
	
	# Create particle material
	var particle_material = ParticleProcessMaterial.new()
	particle_material.direction = Vector3(0, 0, 1)
	particle_material.spread = 15.0
	particle_material.gravity = Vector3(0, 0, 0)
	particle_material.initial_velocity_min = 1.0
	particle_material.initial_velocity_max = 3.0
	particle_material.color = Color(1.0, 0.5, 0.0, 1.0)
	
	# Create mesh for particles
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 0.1
	sphere_mesh.height = 0.2
	
	# Set up material for particle mesh
	var sphere_material = StandardMaterial3D.new()
	sphere_material.albedo_color = Color(1.0, 0.5, 0.0, 1.0)
	sphere_material.emission_enabled = true
	sphere_material.emission = Color(1.0, 0.5, 0.0, 1.0)
	sphere_material.emission_energy_multiplier = 2.0
	sphere_mesh.material = sphere_material
	
	# Apply to particles
	particles.process_material = particle_material
	particles.draw_pass_1 = sphere_mesh
	particles.emitting = true

func _process(delta):
	# Update lifetime
	current_lifetime += delta
	if current_lifetime > max_lifetime:
		queue_free()
		return
	
	# Move missile forward
	if target and is_instance_valid(target):
		# Calculate direction to target
		var direction = (target.global_position - global_position).normalized()
		
		# Smoothly rotate towards target
		var current_direction = -global_transform.basis.z
		var new_direction = current_direction.lerp(direction, tracking_strength * delta).normalized()
		
		# Look at target
		look_at(global_position + new_direction, Vector3.UP)
		
		# Move forward
		global_position += -global_transform.basis.z * speed * delta
	else:
		# If target is lost, continue in current direction
		global_position += -global_transform.basis.z * speed * delta

func set_target(new_target):
	target = new_target
	# Initially look towards target
	look_at(target.global_position, Vector3.UP)

func _on_body_entered(body):
	# Check if we hit an enemy
	if body.is_in_group("enemies"):
		# Deal damage to enemy
		body.take_damage(damage)
		
		# Create explosion effect
		create_explosion()
		
		# Remove missile
		queue_free()

func create_explosion():
	# Create explosion particles
	var explosion_particles = GPUParticles3D.new()
	get_parent().add_child(explosion_particles)
	explosion_particles.global_position = global_position
	
	# Set up particles
	explosion_particles.amount = 50
	explosion_particles.lifetime = 1.0
	explosion_particles.one_shot = true
	explosion_particles.explosiveness = 0.9
	explosion_particles.emitting = true
	
	# Remove particles when done
	await get_tree().create_timer(1.5).timeout
	explosion_particles.queue_free()
