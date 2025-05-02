extends Control

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	set_process_input(true)
	$VBoxContainer/ResumeButton.grab_focus()

func _input(event):
	if event.is_action_pressed("p1_x") or event.is_action_pressed("p2_x"):
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
