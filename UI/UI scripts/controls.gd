extends Control

@onready var back_button = $VBoxContainer/BackButton

func _ready():
	await get_tree().process_frame
	set_process_input(true)
	back_button.grab_focus()

	if not back_button.is_connected("pressed", Callable(self, "_on_back_button_pressed")):
		back_button.connect("pressed", Callable(self, "_on_back_button_pressed"))

func _unhandled_input(event):
	if event.is_action_pressed("p1_a") or event.is_action_pressed("p2_a"):
		back_button.emit_signal("pressed")
		
func _on_back_button_pressed() -> void:
	if Global.previous_scene_path == "res://UI/UI scenes/PauseMenu2P.tscn":
		Global.resume_game()

		var pause_menu_res = load("res://UI/UI scenes/PauseMenu2P.tscn")
		if pause_menu_res:
			var pause_menu = pause_menu_res.instantiate()
			get_tree().current_scene.add_child(pause_menu)
			Global.pause_menu = pause_menu
			pause_menu.visible = true
			get_tree().paused = true

	elif Global.previous_scene_path == "res://UI/UI scenes/mainMenu_2.tscn":
		get_tree().change_scene_to_file("res://UI/UI scenes/mainMenu_2.tscn")

	else:
		print("Invalid or missing previous_scene_path, returning to main menu")
		get_tree().change_scene_to_file("res://UI/UI scenes/MainMenu.tscn")

	Global.previous_scene_path = ""
