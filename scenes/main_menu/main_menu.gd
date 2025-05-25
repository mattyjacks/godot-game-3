extends Control

func _ready():
	# Set up for mobile display
	if OS.get_name() == "Android" or OS.get_name() == "iOS":
		# Adjust UI for mobile if needed
		pass

func _on_game1_button_pressed():
	# Load Game 1
	_load_game("res://scenes/games/game1/game1.tscn")

func _on_game2_button_pressed():
	# Load Game 2
	_load_game("res://scenes/games/game2/game2.tscn")

func _on_game3_button_pressed():
	# Load Game 3
	_load_game("res://scenes/games/game3/game3.tscn")

func _load_game(game_path):
	# You can add transition effects here
	print("Loading game: " + game_path)
	# Change scene to the selected game
	get_tree().change_scene_to_file(game_path)
