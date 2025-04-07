extends Node2D

var is_two_player_mode := false

func set_2_players(enable: bool):
	is_two_player_mode = enable
	print(">> Player mode set to:", is_two_player_mode)

func _ready():
	print(">> Scene loaded, 2P mode is:", is_two_player_mode)

	if is_two_player_mode:
		print(">> Showing Player 2")
		$CharacterBodyP2.show()
	else:
		print(">> Hiding Player 2")
		$CharacterBodyP2.hide()
