extends Control

func _ready():
	await get_tree().process_frame  # Wait a frame to ensure UI is ready
	$ColorRect/VBoxContainer/PlayAgain.grab_focus()

func _on_play_again_pressed() -> void:
	print("Play Again pressed")
	get_tree().paused = false

	# Reset all global player stats
	Global.reset_stats()

	# Clear any pause menu leftovers
	Global.pause_menu = null

	# Clean up all non-autoload nodes (leftover gameplay/UI)
	for node in get_tree().get_root().get_children():
		if not node.is_in_group("autoload"):  # Keep autoloads
			node.queue_free()

	# Defer the scene change to ensure it occurs after cleanup
	# This ensures cleanup is complete before changing scenes
	get_tree().call_deferred("change_scene_to_file", "res://UI/UI scenes/MainMenu.tscn")
	
	# Optional: Print for debuggin
	print("Scene change deferred to MainMenu")


func _on_see_your_score_pressed() -> void:
	print("Show score logic goes here.")
	# You can switch to a leaderboard or summary scene here

func _on_quit_game_pressed() -> void:
	get_tree().quit()

func _unhandled_input(event):
	if event.is_action_pressed("p1_up") or event.is_action_pressed("p2_up"):
		var focused = get_viewport().gui_get_focus_owner()
		if focused:
			var neighbor_path = focused.get_focus_neighbor(SIDE_TOP)
			if neighbor_path:
				var neighbor = focused.get_node(neighbor_path)
				if neighbor:
					neighbor.grab_focus()

	elif event.is_action_pressed("p1_down") or event.is_action_pressed("p2_down"):
		var focused = get_viewport().gui_get_focus_owner()
		if focused:
			var neighbor_path = focused.get_focus_neighbor(SIDE_BOTTOM)
			if neighbor_path:
				var neighbor = focused.get_node(neighbor_path)
				if neighbor:
					neighbor.grab_focus()

	if event.is_action_pressed("p1_a") or event.is_action_pressed("p2_a"):
		var focused = get_viewport().gui_get_focus_owner()
		if focused and focused is Button:
			focused.emit_signal("pressed")
