extends Control

func _ready():
	get_tree().paused = true
	$VBoxContainer/PlayAgain.grab_focus()

func _on_play_again_pressed() -> void:
	print("Play Again pressed")
	get_tree().paused = false

	Global.reset_stats()

	# Remove this screen
	queue_free()

	# Clean up all non-autoload nodes
	for node in get_tree().get_root().get_children():
		if node.name != "Global":
			node.queue_free()

	await get_tree().process_frame

	Global.pause_menu = null

	# Use deferred call to avoid scene switch while nodes are being deleted
	call_deferred("go_to_main_menu")

func go_to_main_menu():
	get_tree().change_scene_to_file("res://UI/UI scenes/MainMenu.tscn")

func _on_see_your_score_pressed() -> void:
	Global.previous_scene_path = "res://UI/UI scenes/YouDiedScreen.tscn"

	var packed_scene = load("res://UI/UI scenes/ScoreScene.tscn")
	if packed_scene:
		var score_scene = packed_scene.instantiate()
		score_scene.player1_score = Global.player1_score
		score_scene.player2_score = Global.player2_score
		score_scene.two_player_mode = Global.is_two_player_mode
		get_tree().get_root().add_child(score_scene)
		queue_free()


func _on_quit_game_pressed() -> void:
	get_tree().quit()

func _unhandled_input(event):
	if event.is_action_pressed("p1_up") or event.is_action_pressed("p2_up"):
		var focused = get_viewport().gui_get_focus_owner()
		var neighbor_path = focused.get_focus_neighbor(SIDE_TOP)
		if neighbor_path:
			var neighbor = focused.get_node(neighbor_path)
			neighbor.grab_focus()

	elif event.is_action_pressed("p1_down") or event.is_action_pressed("p2_down"):
		var focused = get_viewport().gui_get_focus_owner()
		var neighbor_path = focused.get_focus_neighbor(SIDE_BOTTOM)
		if neighbor_path:
			var neighbor = focused.get_node(neighbor_path)
			neighbor.grab_focus()

	if event.is_action_pressed("p1_a") or event.is_action_pressed("p2_a"):
		var focused = get_viewport().gui_get_focus_owner()
		if focused and focused is Button:
			focused.emit_signal("pressed")
