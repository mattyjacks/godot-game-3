extends CharacterBody3D

# Pilot parameters
var fall_speed = 2.0
var drift_speed = 1.0
var time_alive = 0.0
var max_lifetime = 15.0

func _ready():
	# Set up materials
	var pilot_mat = StandardMaterial3D.new()
	pilot_mat.albedo_color = Color(0.2, 0.2, 0.7)  # Blue uniform
	$PilotMesh.material_override = pilot_mat
	
	var parachute_mat = StandardMaterial3D.new()
	parachute_mat.albedo_color = Color(0.9, 0.9, 0.9)  # White parachute
	$ParachuteMesh.material_override = parachute_mat
	
	# Set up blood particles
	var particles = $BloodParticles
	particles.emitting = false
	
	# Connect signal to player
	var player = get_tree().get_nodes_in_group("player")
	if player.size() > 0:
		player[0].connect("hit_parachute", Callable(self, "explode_with_blood"))

func _process(delta):
	# Update lifetime
	time_alive += delta
	if time_alive > max_lifetime:
		queue_free()
		return
	
	# Apply gravity
	velocity.y = -fall_speed
	
	# Add some drifting
	velocity.x = sin(time_alive * 0.5) * drift_speed
	velocity.z = cos(time_alive * 0.7) * drift_speed
	
	# Apply movement
	move_and_slide()
	
	# Check if pilot has fallen below the world
	if position.y < -20:
		queue_free()

func _on_collision_area_body_entered(body):
	# Check if we collided with player
	if body.is_in_group("player"):
		# Emit signal to player
		body.emit_signal("hit_parachute", self)
		
		# Explode with blood
		explode_with_blood()

func explode_with_blood():
	# Hide pilot and parachute
	$PilotMesh.visible = false
	$ParachuteMesh.visible = false
	$ParachuteStrings.visible = false
	
	# Set up blood particles
	var particles = $BloodParticles
	
	# Create material for blood particles
	var particle_material = StandardMaterial3D.new()
	particle_material.albedo_color = Color(0.8, 0.0, 0.0)  # Red blood
	
	# Set up particle mesh
	var particle_mesh = SphereMesh.new()
	particle_mesh.radius = 0.05
	particle_mesh.height = 0.1
	particle_mesh.material = particle_material
	
	# Configure particles
	particles.draw_pass_1 = particle_mesh
	particles.emitting = true
	
	# Play blood splatter sound
	play_blood_sound()
	
	# Remove pilot after particles finish
	await get_tree().create_timer(2.0).timeout
	queue_free()

func play_blood_sound():
	# Create audio player for blood splatter sound
	var audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	
	# Set up audio stream
	var sound = AudioStreamWAV.new()
	# In a real implementation, you would load an actual sound file
	
	audio_player.stream = sound
	audio_player.volume_db = -10
	audio_player.pitch_scale = randf_range(0.9, 1.1)
	audio_player.play()
	
	# Remove audio player when done
	await audio_player.finished
	audio_player.queue_free()
