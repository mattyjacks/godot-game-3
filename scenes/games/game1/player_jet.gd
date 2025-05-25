extends CharacterBody3D

signal hit_parachute(pilot)

# Movement parameters
var movement_speed = 15.0
var rotation_speed = 3.0
var max_x_position = 25.0
var max_y_position = 15.0
var target_position = Vector3.ZERO
var missile_scene = preload("res://scenes/games/game1/missile.tscn")

# Movement input
var movement_input = Vector2.ZERO

func _ready():
	# Initialize starting position
	position = Vector3(0, 5, 5)
	target_position = position

func _process(delta):
	# Handle movement based on input
	handle_movement(delta)
	
	# Handle rotation for banking effect
	handle_rotation(delta)

func handle_movement(delta):
	# Calculate target position based on input
	target_position.x = clamp(position.x + movement_input.x * movement_speed * delta, -max_x_position, max_x_position)
	target_position.y = clamp(position.y + movement_input.y * movement_speed * delta, 0, max_y_position)
	
	# Smooth movement towards target position
	position = position.lerp(target_position, 0.2)

func handle_rotation(delta):
	# Bank the aircraft based on horizontal movement
	var target_z_rotation = -movement_input.x * 0.5  # Bank when turning
	rotation.z = lerp(rotation.z, target_z_rotation, rotation_speed * delta)
	
	# Pitch based on vertical movement
	var target_x_rotation = movement_input.y * 0.3  # Pitch when climbing/diving
	rotation.x = lerp(rotation.x, target_x_rotation, rotation_speed * delta)

func set_movement(x, y):
	movement_input = Vector2(x, y)

func fire_missile(target):
	# Create missile instance
	var missile_instance = missile_scene.instantiate()
	get_parent().add_child(missile_instance)
	
	# Set missile position and target
	missile_instance.global_position = $MissileSpawnPoint.global_position
	missile_instance.set_target(target)
	
	# Play sound effect
	play_fire_sound()

func play_fire_sound():
	# Create audio player for missile launch sound
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

func _on_area_entered(area):
	# Check if we hit a parachuting pilot
	if area.is_in_group("pilots"):
		emit_signal("hit_parachute", area)
		area.queue_free()
