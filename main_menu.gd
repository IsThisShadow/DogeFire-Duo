extends Control

func _ready():
	$VBoxContainer/OnePlayerButton.text = "1 Player"
	$VBoxContainer/TwoPlayerButton.text = "2 Players"

	$VBoxContainer/OnePlayerButton.pressed.connect(_on_one_player)
	$VBoxContainer/TwoPlayerButton.pressed.connect(_on_two_player)

func _on_one_player():
	_load_game_scene(false)

func _on_two_player():
	_load_game_scene(true)

func _load_game_scene(is_two_player: bool):
	var scene_path = "res://scripts/PlayerScripts/Levels/main.tscn"
	var packed_scene = load(scene_path)
	
	if packed_scene:
		var game_scene = packed_scene.instantiate()

		# Set player mode BEFORE adding to the tree
		game_scene.set_2_players(is_two_player)

		# Swap scene
		var current = get_tree().current_scene
		if current:
			current.queue_free()

		get_tree().get_root().add_child(game_scene)
		get_tree().current_scene = game_scene
	else:
		print(" Failed to load scene:", scene_path)
