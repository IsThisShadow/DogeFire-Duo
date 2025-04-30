extends Control
"""
On entering level 2 the pause button does not hide the player.

During the entering Level 2 menu, when pressing start and pressing pause immediately after, 
nothing is hidden on the pause menu.
"""
func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false  # Hide until shown
	set_process_input(true)

func _input(event):
	if event.is_action_pressed("p1_x") or event.is_action_pressed("p2_x"):
		Global.resume_game()


func _on_resume_button_pressed() -> void:
	Global.resume_game()


func _on_return_main_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://MainMenu.tscn")


func _on_quit_game_button_pressed() -> void:
	get_tree().quit()
