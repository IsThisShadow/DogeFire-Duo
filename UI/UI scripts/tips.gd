extends Control

func _on_back_button_pressed() -> void:
	if Global.previous_scene_path != "":
		Global.resume_game()  # Important: unpause first
		get_tree().change_scene_to_file(Global.previous_scene_path)
		Global.previous_scene_path = ""
	else:
		print("No previous scene path set")
