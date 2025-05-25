extends CharacterBody3D

signal destroyed

# Enemy parameters
var health = 100
var movement_speed = 5.0
var pilot_scene = preload("res://scenes/games/game1/pilot_parachute.tscn")
var explosion_scene = preload("res://scenes/games/game1/explosion.tscn")

# Movement pattern
var time_passed = 0.0
var movement_pattern = randi() % 3  # 0: straight, 1: sine wave, 2: circle

func _ready():
	# Randomize initial rotation for variety
	rotation.y = randf_range(0, PI * 2)
	
	# Set up materials with random color variations for enemy jets
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.7, 0.2, 0.2)  # Reddish for enemies
	$JetBody.material_override = mat
	$JetWings.material_override = mat

func _process(delta):
	# Update time for movement patterns
	time_passed += delta
	
	# Apply movement pattern
	match movement_pattern:
		0:  # Straight movement with slight wobble
			velocity.x = sin(time_passed * 0.5) * 2.0
			velocity.y = cos(time_passed * 0.3) * 1.0
		1:  # Sine wave pattern
			velocity.x = sin(time_passed * 2.0) * 5.0
			velocity.y = cos(time_passed * 1.5) * 2.0
		2:  # Circular pattern
			velocity.x = sin(time_passed) * 8.0
			velocity.y = cos(time_passed) * 4.0
	
	# Apply movement
	move_and_slide()
	
	# Check if enemy is too far behind
	if position.z > 30:
		queue_free()

func take_damage(damage_amount):
	health -= damage_amount
	
	if health <= 0:
		destroy()

func destroy():
	# Spawn explosion
	var explosion_instance = explosion_scene.instantiate()
	get_parent().add_child(explosion_instance)
	explosion_instance.global_position = global_position
	explosion_instance.emitting = true
	
	# Spawn pilot with parachute
	spawn_pilot()
	
	# Add score to game
	get_parent().add_score(100)
	
	# Play explosion sound
	play_explosion_sound()
	
	# Remove enemy jet
	emit_signal("destroyed")
	queue_free()

func spawn_pilot():
	var pilot_instance = pilot_scene.instantiate()
	get_parent().add_child(pilot_instance)
	pilot_instance.global_position = global_position
	pilot_instance.add_to_group("pilots")
	
	# Apply slight random velocity to pilot
	pilot_instance.velocity = Vector3(
		randf_range(-2, 2),
		randf_range(-1, -3),  # Initial downward velocity
		randf_range(-1, 1)
	)

func play_explosion_sound():
	# Create audio player for explosion sound
	var audio_player = AudioStreamPlayer.new()
	get_parent().add_child(audio_player)
	
	# Set up audio stream
	var sound = AudioStreamWAV.new()
	# In a real implementation, you would load an actual sound file
	
	audio_player.stream = sound
	audio_player.volume_db = -5
	audio_player.pitch_scale = randf_range(0.8, 1.2)
	audio_player.play()
	
	# Remove audio player when done
	await audio_player.finished
	audio_player.queue_free()
