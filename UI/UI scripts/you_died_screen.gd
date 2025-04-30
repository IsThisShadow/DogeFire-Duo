extends Control

func _on_play_again_pressed() -> void:
	print("Play Again pressed")
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
	get_tree().change_scene_to_file("res://UI/UI scenes/MainMenu.tscn")

func _on_see_your_score_pressed() -> void:
	print("Show score logic goes here.")
	# You can switch to a leaderboard or summary scene here

func _on_quit_game_pressed() -> void:
	get_tree().quit()
