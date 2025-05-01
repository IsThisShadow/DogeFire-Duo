extends Control

func _ready():
	$VBoxContainer/OnePlayerButton.grab_focus()
	$VBoxContainer/OnePlayerButton.text = "1 Player"
	$VBoxContainer/TwoPlayerButton.text = "2 Players"

	$VBoxContainer/OnePlayerButton.pressed.connect(_on_one_player)
	$VBoxContainer/TwoPlayerButton.pressed.connect(_on_two_player)

func _on_one_player():
	_load_ready_screen(false)

func _on_two_player():
	_load_ready_screen(true)

func _load_ready_screen(is_two_player: bool):
	var menu2_scene = preload("res://UI/UI scenes/mainMenu_2.tscn").instantiate()
	Global.is_two_player_mode = is_two_player

	var current = get_tree().current_scene
	if current:
		current.queue_free()

	get_tree().get_root().add_child(menu2_scene)
	get_tree().current_scene = menu2_scene

func _unhandled_input(event):
	if event.is_action_pressed("p1_up") or event.is_action_pressed("p2_up"):
		var focused = get_viewport().gui_get_focus_owner()
		var neighbor = focused.get_focus_neighbor(0) # TOP
		if neighbor:
			neighbor.grab_focus()

	elif event.is_action_pressed("p1_down") or event.is_action_pressed("p2_down"):
		var focused = get_viewport().gui_get_focus_owner()
		var neighbor = focused.get_focus_neighbor(1) # BOTTOM
		if neighbor:
			neighbor.grab_focus()

	if event.is_action_pressed("p1_a") or event.is_action_pressed("p2_a"):
		var focused = get_viewport().gui_get_focus_owner()
		if focused and focused is Button:
			focused.emit_signal("pressed")
