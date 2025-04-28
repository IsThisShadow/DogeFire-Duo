extends Control

@onready var play_again_button = $PlayAgain_button
@onready var quit_game_button = $Quit_button

func _ready():
	# Connect buttons
	play_again_button.pressed.connect(_on_play_again_pressed)
	quit_game_button.pressed.connect(_on_quit_game_pressed)

func _on_play_again_pressed():
	# Load the Main Menu scene
	get_tree().change_scene_to_file("res://MainMenu.tscn")

func _on_quit_game_pressed():
	# Quit the entire game
	get_tree().quit()
