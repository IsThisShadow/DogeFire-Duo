extends Control

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false  # Hide until shown
	set_process_input(true)

	# Safely set initial focus
	var resume_button = $VBoxContainer/ResumeButton
	if resume_button is Control:
		resume_button.grab_focus()

func _unhandled_input(event):
	if event.is_action_pressed("p1_up") or event.is_action_pressed("p2_up"):
		var focused = get_viewport().gui_get_focus_owner()
		if focused is Control:
			var neighbor = focused.get_focus_neighbor(SIDE_TOP)
			if neighbor is Control:
				neighbor.grab_focus()

	elif event.is_action_pressed("p1_down") or event.is_action_pressed("p2_down"):
		var focused = get_viewport().gui_get_focus_owner()
		if focused is Control:
			var neighbor = focused.get_focus_neighbor(SIDE_BOTTOM)
			if neighbor is Control:
				neighbor.grab_focus()

	elif event.is_action_pressed("p1_a") or event.is_action_pressed("p2_a"):
		var focused = get_viewport().gui_get_focus_owner()
		if focused is Button:
			focused.emit_signal("pressed")

	elif event.is_action_pressed("p1_x") or event.is_action_pressed("p2_x"):
		Global.resume_game()

func _on_resume_button_pressed() -> void:
	Global.resume_game()

func _on_return_main_menu_button_pressed() -> void:
	Global.resume_game() 
	call_deferred("go_to_main_menu")

func go_to_main_menu():
	get_tree().change_scene_to_file("res://UI/UI scenes/MainMenu.tscn")

func _on_quit_game_button_pressed() -> void:
	get_tree().quit()
