extends Control

var joystick_cooldown := 0.2
var joystick_timer := 0.0
var p1_up_ready := true
var p1_down_ready := true
var p2_up_ready := true
var p2_down_ready := true
var is_armed := false  # Prevents immediate resume on re-entry

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	Global.pause_menu = self
	visible = true
	set_process_input(true)
	$VBoxContainer/ResumeButton.grab_focus()
	get_tree().paused = true

	# Wait one frame to avoid catching old input
	await get_tree().process_frame
	is_armed = true

func _process(delta):
	joystick_timer -= delta

	if Input.is_action_pressed("p1_up") and p1_up_ready and joystick_timer <= 0.0:
		move_focus_up()
		joystick_timer = joystick_cooldown
		p1_up_ready = false
	elif not Input.is_action_pressed("p1_up"):
		p1_up_ready = true

	if Input.is_action_pressed("p1_down") and p1_down_ready and joystick_timer <= 0.0:
		move_focus_down()
		joystick_timer = joystick_cooldown
		p1_down_ready = false
	elif not Input.is_action_pressed("p1_down"):
		p1_down_ready = true

	if Input.is_action_pressed("p2_up") and p2_up_ready and joystick_timer <= 0.0:
		move_focus_up()
		joystick_timer = joystick_cooldown
		p2_up_ready = false
	elif not Input.is_action_pressed("p2_up"):
		p2_up_ready = true

	if Input.is_action_pressed("p2_down") and p2_down_ready and joystick_timer <= 0.0:
		move_focus_down()
		joystick_timer = joystick_cooldown
		p2_down_ready = false
	elif not Input.is_action_pressed("p2_down"):
		p2_down_ready = true

func move_focus_up():
	var focused = get_viewport().gui_get_focus_owner()
	var neighbor_path = focused.get_focus_neighbor(SIDE_TOP)
	if neighbor_path:
		var neighbor = focused.get_node(neighbor_path)
		neighbor.grab_focus()

func move_focus_down():
	var focused = get_viewport().gui_get_focus_owner()
	var neighbor_path = focused.get_focus_neighbor(SIDE_BOTTOM)
	if neighbor_path:
		var neighbor = focused.get_node(neighbor_path)
		neighbor.grab_focus()

func _unhandled_input(event):
	if event.is_action_pressed("p1_a") or event.is_action_pressed("p2_a"):
		var focused = get_viewport().gui_get_focus_owner()
		if focused and focused is Button:
			focused.emit_signal("pressed")

func _input(event):
	if is_armed and (event.is_action_pressed("p1_x") or event.is_action_pressed("p2_x")):
		if visible:
			Global.previous_scene_path = ""
			Global.resume_game()

func _on_resume_button_pressed() -> void:
	Global.previous_scene_path = ""
	Global.resume_game()

func _on_return_main_menu_button_pressed() -> void:
	Global.resume_game()
	Global.reset_stats()
	call_deferred("go_to_main_menu")

func go_to_main_menu():
	get_tree().change_scene_to_file("res://UI/UI scenes/MainMenu.tscn")

func _on_quit_game_button_pressed() -> void:
	get_tree().quit()
