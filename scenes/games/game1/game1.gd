extends Node3D

# Game variables
var score = 0
var enemy_scene = preload("res://scenes/games/game1/enemy_jet.tscn")
var cloud_scene = preload("res://scenes/games/game1/cloud.tscn")
var mountain_scene = preload("res://scenes/games/game1/mountain.tscn")
var game_speed = 10.0
var lock_on_time = 0.0
var current_target = null
var lock_on_duration = 1.0  # 1 second to lock on

# Environment setup
@onready var player_jet = $PlayerJet
@onready var camera = $Camera3D
@onready var clouds_parent = $Clouds
@onready var mountains_parent = $Mountains
@onready var score_label = $UI/ControlPanel/ScoreLabel
@onready var joystick_handle = $UI/ControlPanel/JoystickControl/JoystickHandle
@onready var joystick_background = $UI/ControlPanel/JoystickControl/JoystickBackground
@onready var lock_on_progress = $UI/ControlPanel/LockOnProgress

# Touch control variables
var joystick_active = false
var joystick_origin = Vector2.ZERO
var current_joystick_pos = Vector2.ZERO
var joystick_vector = Vector2.ZERO

func _ready():
	# Set up environment
	setup_environment()
	setup_clouds()
	setup_mountains()
	
	# Set up touch controls
	setup_touch_controls()
	
	# Initialize UI
	score_label.text = "Score: " + str(score)
	lock_on_progress.value = 0
	
	# Make sure player is in the player group
	player_jet.add_to_group("player")
	
	# Connect player signals
	player_jet.connect("hit_parachute", Callable(self, "_on_player_hit_parachute"))

func setup_environment():
	# Create world environment with sky
	var environment = Environment.new()
	environment.background_mode = Environment.BG_SKY
	
	var sky = Sky.new()
	var sky_material = ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color(0.1, 0.4, 0.8)
	sky_material.sky_horizon_color = Color(0.7, 0.8, 0.9)
	sky_material.ground_bottom_color = Color(0.1, 0.1, 0.1)
	sky_material.ground_horizon_color = Color(0.7, 0.8, 0.9)
	sky_material.sun_angle_max = 30.0
	sky_material.sun_curve = 0.15
	
	# Add sun to the sky
	sky_material.sun_angle_max = 10.0  # Smaller angle makes the sun appear larger
	sky_material.sun_curve = 0.05  # Sharper curve for more defined sun
	
	sky.sky_material = sky_material
	environment.sky = sky
	
	# Add fog for distance effect
	environment.fog_enabled = true
	environment.fog_light_color = Color(0.8, 0.8, 0.9)
	environment.fog_light_energy = 0.3
	environment.fog_density = 0.001
	
	# Set up visual effects
	environment.ssao_enabled = true
	environment.glow_enabled = true
	environment.glow_bloom = 0.2
	environment.glow_hdr_threshold = 0.9
	
	$WorldEnvironment.environment = environment
	
	# Adjust directional light for better sun rays
	$DirectionalLight3D.light_energy = 2.0
	$DirectionalLight3D.shadow_enabled = true

func setup_clouds():
	# Create initial clouds
	for i in range(15):
		spawn_cloud(true)

func setup_mountains():
	# Create initial mountains
	for i in range(5):
		spawn_mountain(true)

func spawn_cloud(is_initial = false):
	var cloud_instance = cloud_scene.instantiate()
	clouds_parent.add_child(cloud_instance)
	
	# Position the cloud
	var x_pos = randf_range(-50, 50)
	var y_pos = randf_range(10, 40)
	var z_pos = -100
	
	if is_initial:
		z_pos = randf_range(-100, 100)
	
	cloud_instance.position = Vector3(x_pos, y_pos, z_pos)
	cloud_instance.scale = Vector3.ONE * randf_range(5, 15)
	cloud_instance.rotation.y = randf_range(0, 2 * PI)

func spawn_mountain(is_initial = false):
	var mountain_instance = mountain_scene.instantiate()
	mountains_parent.add_child(mountain_instance)
	
	# Position the mountain
	var x_pos = randf_range(-100, 100)
	var z_pos = -200
	
	if is_initial:
		z_pos = randf_range(-200, 0)
	
	mountain_instance.position = Vector3(x_pos, -10, z_pos)
	mountain_instance.scale = Vector3.ONE * randf_range(10, 20)

func setup_touch_controls():
	# Set up joystick visuals
	var joystick_bg_texture = CircleShape2D.new()
	joystick_bg_texture.radius = 75
	joystick_background.texture = joystick_bg_texture
	
	var joystick_handle_texture = CircleShape2D.new()
	joystick_handle_texture.radius = 30
	joystick_handle.texture = joystick_handle_texture
	
	# Reset joystick position
	joystick_origin = joystick_background.global_position
	current_joystick_pos = joystick_origin

func _process(delta):
	# Move everything forward (simulating jet movement)
	move_world_objects(delta)
	
	# Handle lock-on mechanics
	handle_lock_on(delta)
	
	# Update UI
	update_ui()

func move_world_objects(delta):
	# Move clouds
	for cloud in clouds_parent.get_children():
		cloud.position.z += game_speed * delta
		
		# If cloud is behind camera, reposition it
		if cloud.position.z > 20:
			cloud.queue_free()
			spawn_cloud()
	
	# Move mountains
	for mountain in mountains_parent.get_children():
		mountain.position.z += game_speed * delta
		
		# If mountain is behind camera, reposition it
		if mountain.position.z > 20:
			mountain.queue_free()
			spawn_mountain()
	
	# Move enemies
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.position.z += game_speed * 0.5 * delta  # Enemies move slower than environment

func handle_lock_on(delta):
	# Check if we have a valid target
	if current_target and is_instance_valid(current_target) and current_target.is_in_group("enemies"):
		# Check if player is aiming at the enemy
		var enemy_screen_pos = camera.unproject_position(current_target.global_position)
		var screen_center = get_viewport().size / 2
		var distance = enemy_screen_pos.distance_to(screen_center)
		
		# If enemy is in center of screen (player is aiming at it)
		if distance < 100:
			lock_on_time += delta
			if lock_on_time >= lock_on_duration:
				# Locked on and ready to fire
				lock_on_progress.value = 1.0
				lock_on_progress.modulate = Color(1, 0, 0)  # Red when locked
			else:
				# Still locking on
				lock_on_progress.value = lock_on_time / lock_on_duration
				lock_on_progress.modulate = Color(1, 1, 0)  # Yellow while locking
			
			lock_on_progress.visible = true
		else:
			# Lost lock
			reset_lock_on()
	else:
		# Find new potential target
		var enemies = get_tree().get_nodes_in_group("enemies")
		if enemies.size() > 0:
			# Find closest enemy in front of player
			var closest_dist = 1000
			for enemy in enemies:
				var enemy_screen_pos = camera.unproject_position(enemy.global_position)
				var screen_center = get_viewport().size / 2
				var distance = enemy_screen_pos.distance_to(screen_center)
				
				if distance < closest_dist and enemy.position.z < 0:
					closest_dist = distance
					current_target = enemy
			
			if closest_dist < 100:
				lock_on_progress.visible = true
			else:
				reset_lock_on()
		else:
			reset_lock_on()

func reset_lock_on():
	lock_on_time = 0
	lock_on_progress.value = 0
	lock_on_progress.visible = false

func update_ui():
	score_label.text = "Score: " + str(score)

func _input(event):
	# Handle touch input for joystick
	if event is InputEventScreenTouch:
		var touch_pos = event.position
		
		# Check if touch is in joystick area
		if touch_pos.distance_to(joystick_origin) < 100:
			if event.pressed:
				joystick_active = true
			else:
				joystick_active = false
				reset_joystick()
	
	# Handle touch drag for joystick
	elif event is InputEventScreenDrag and joystick_active:
		var drag_pos = event.position
		var stick_vector = (drag_pos - joystick_origin).limit_length(75)
		current_joystick_pos = joystick_origin + stick_vector
		joystick_handle.global_position = current_joystick_pos
		
		# Calculate normalized vector for player movement
		var movement = stick_vector / 75
		player_jet.set_movement(movement.x, -movement.y)  # Invert Y for flight controls

func reset_joystick():
	joystick_handle.global_position = joystick_origin
	player_jet.set_movement(0, 0)

func _on_enemy_spawn_timer_timeout():
	# Spawn a new enemy
	var enemy_instance = enemy_scene.instantiate()
	add_child(enemy_instance)
	
	# Position the enemy
	var x_pos = randf_range(-20, 20)
	var y_pos = randf_range(0, 15)
	enemy_instance.position = Vector3(x_pos, y_pos, -100)
	
	# Add to enemy group
	enemy_instance.add_to_group("enemies")

func _on_fire_button_pressed():
	# Check if we have a locked target
	if current_target and is_instance_valid(current_target) and lock_on_time >= lock_on_duration:
		# Fire missile at target
		player_jet.fire_missile(current_target)
		
		# Reset lock-on
		reset_lock_on()

func add_score(points):
	score += points
	score_label.text = "Score: " + str(score)

func _on_player_hit_parachute(pilot):
	# Add bonus points when hitting a parachuting pilot
	add_score(50)
	
	# Show blood particles
	pilot.explode_with_blood()
