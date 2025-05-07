extends Control

@onready var back_button = $VBoxContainer/BackButton

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process_input(true)
	back_button.grab_focus()

	if not back_button.is_connected("pressed", Callable(self, "_on_back_button_pressed")):
		back_button.connect("pressed", Callable(self, "_on_back_button_pressed"))

func _unhandled_input(event):
	if event.is_action_pressed("p1_a") or event.is_action_pressed("p2_a"):
		back_button.emit_signal("pressed")

func _on_back_button_pressed() -> void:
	if Global.previous_scene_path == "res://UI/UI scenes/PauseMenu2P.tscn":
		# Leave return_to_pause_menu = true so Global.gd ignores toggle input once
		var pause_menu_scene = load(Global.previous_scene_path)
		if pause_menu_scene:
			var pause_menu = pause_menu_scene.instantiate()
			get_tree().get_root().add_child(pause_menu)

			Global.pause_menu = pause_menu
			get_tree().paused = true

			await get_tree().process_frame
			queue_free()  # Clean up this Controls scene
		else:
			print("Failed to load PauseMenu2P.tscn")
	else:
		get_tree().change_scene_to_file("res://UI/UI scenes/mainMenu_2.tscn")
