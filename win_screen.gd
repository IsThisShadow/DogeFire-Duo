extends Control

@onready var play_again_button = $PlayAgain_button
@onready var quit_game_button = $Quit_button

func _ready():
	# Connect buttons
	play_again_button.pressed.connect(_on_play_again_pressed)
	quit_game_button.pressed.connect(_on_quit_game_pressed)

func _on_play_again_pressed():
	get_tree().paused = false

	#  Reset all global player stats
	Global.reset_stats()

	# Remove this screen
	queue_free()

	# Clean up all non-autoload nodes (leftover gameplay/UI)
	for node in get_tree().get_root().get_children():
		if node.name != "Global":  # Keep autoloads
			node.queue_free()

	await get_tree().process_frame  # Let cleanup happen

	#  Clear any pause menu leftovers
	Global.pause_menu = null

	#  Go back to main menu
	get_tree().change_scene_to_file("res://MainMenu.tscn")


func _on_quit_game_pressed():
	# Quit the entire game
	get_tree().quit()
