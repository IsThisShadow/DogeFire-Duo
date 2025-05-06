extends Control

@onready var back_button = $BackButton

func _ready():
	back_button.grab_focus()
	set_process_input(true)

	if not back_button.is_connected("pressed", Callable(self, "_on_back_button_pressed")):
		back_button.connect("pressed", Callable(self, "_on_back_button_pressed"))

func _unhandled_input(event):
	if event.is_action_pressed("p1_a") or event.is_action_pressed("p2_a"):
		back_button.emit_signal("pressed")

func _on_back_button_pressed() -> void:
	if Global.return_to_pause_menu:
		Global.return_to_pause_menu = false
		get_tree().change_scene_to_file(Global.previous_scene_path)
	else:
		get_tree().change_scene_to_file("res://UI/UI scenes/mainMenu_2.tscn")
