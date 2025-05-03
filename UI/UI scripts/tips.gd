extends Control
@onready var back_button = $Button


func _ready():
	back_button.grab_focus()
	set_process_input(true)

func _input(event):
	if event.is_action_pressed("p1_a") or event.is_action_pressed("p2_a"):
		if back_button.has_focus():
			back_button.emit_signal("pressed")


func _on_button_pressed() -> void:
	if Global.previous_scene_path != "":
		Global.resume_game()

		var scene_res = load(Global.previous_scene_path)
		if scene_res:
			var level_scene = scene_res.instantiate()

			# Replace current scene with the level
			var current = get_tree().current_scene
			if current:
				current.queue_free()

			get_tree().get_root().add_child(level_scene)
			get_tree().current_scene = level_scene

			# Wait for scene to fully initialize
			await get_tree().process_frame
			await get_tree().process_frame

			# Manually instance the pause menu and add it
			var pause_menu_res = load("res://UI/UI scenes/PauseMenu2P.tscn")
			if pause_menu_res:
				var pause_menu = pause_menu_res.instantiate()
				level_scene.add_child(pause_menu)
				pause_menu.visible = true
			else:
				print("Failed to load PauseMenu2P.tscn")
		else:
			print("Failed to load scene:", Global.previous_scene_path)

		Global.previous_scene_path = ""
	else:
		print("No previous scene path set")
