extends Control

var p1_ready := false
var p2_ready := false
var countdown_started := false

var joystick_cooldown := 0.2
var joystick_timer := 0.0
var p1_up_ready := true
var p1_down_ready := true
var p2_up_ready := true
var p2_down_ready := true

func _ready():
	Global.pause_menu = self
	$UIFadeGroup/ReadyWrapperP1/ReadyLabelP1.visible = false
	$UIFadeGroup/ReadyWrapperP2/ReadyLabelP2.visible = false

	$UIFadeGroup/ReadyWrapperP1/ReadyLabelP1.add_theme_color_override("font_color", Color(1, 0.2, 0.2))  # Red
	$UIFadeGroup/ReadyWrapperP2/ReadyLabelP2.add_theme_color_override("font_color", Color(0.4, 0.6, 1.0))  # Blue

	$UIFadeGroup/VBoxContainer/CountdownWrapper/CountdownLabel.text = "Press Start"
	$UIFadeGroup/VBoxContainer/CountdownWrapper/StartFlasher.play("FlashStart")

	$UIFadeGroup/VBoxContainer/ControlButton.grab_focus()

func _process(delta):
	if countdown_started:
		return

	joystick_timer -= delta

	# P1 Up
	if Input.is_action_pressed("p1_up"):
		if p1_up_ready and joystick_timer <= 0.0:
			move_focus_up()
			joystick_timer = joystick_cooldown
			p1_up_ready = false
	else:
		p1_up_ready = true

	# P1 Down
	if Input.is_action_pressed("p1_down"):
		if p1_down_ready and joystick_timer <= 0.0:
			move_focus_down()
			joystick_timer = joystick_cooldown
			p1_down_ready = false
	else:
		p1_down_ready = true

	# P2 Up
	if Input.is_action_pressed("p2_up"):
		if p2_up_ready and joystick_timer <= 0.0:
			move_focus_up()
			joystick_timer = joystick_cooldown
			p2_up_ready = false
	else:
		p2_up_ready = true

	# P2 Down
	if Input.is_action_pressed("p2_down"):
		if p2_down_ready and joystick_timer <= 0.0:
			move_focus_down()
			joystick_timer = joystick_cooldown
			p2_down_ready = false
	else:
		p2_down_ready = true

	if Input.is_action_just_pressed("p1_start") and not p1_ready:
		p1_ready = true
		$UIFadeGroup/ReadyWrapperP1/ReadyLabelP1.visible = true
		$UIFadeGroup/ReadyWrapperP1/ReadyAnimatorP1.play("ZoomIn")
		print("P1 is ready!")

	if Global.is_two_player_mode:
		if Input.is_action_just_pressed("p2_start") and not p2_ready:
			p2_ready = true
			$UIFadeGroup/ReadyWrapperP2/ReadyLabelP2.visible = true
			$UIFadeGroup/ReadyWrapperP2/ReadyAnimatorP2.play("ZoomIn")
			print("P2 is ready!")

		if p1_ready and p2_ready:
			start_countdown()
	else:
		if p1_ready:
			start_countdown()

func _unhandled_input(event):
	if countdown_started:
		return

	if event.is_action_pressed("p1_a") or event.is_action_pressed("p2_a"):
		var focused = get_viewport().gui_get_focus_owner()
		if focused and focused is Button:
			focused.emit_signal("pressed")

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

func start_countdown():
	countdown_started = true
	print(">> Starting countdown!")

	$UIFadeGroup/VBoxContainer/CountdownWrapper/StartFlasher.stop()
	$UIFadeGroup/VBoxContainer/CountdownWrapper/CountdownLabel.modulate.a = 1.0

	await countdown()

func countdown():
	for i in range(5, 0, -1):
		$UIFadeGroup/VBoxContainer/CountdownWrapper/CountdownLabel.text = str(i)
		$UIFadeGroup/VBoxContainer/CountdownWrapper/CountdownAnimator.play("CountdownPulse")
		await get_tree().create_timer(1.0).timeout

	$UIFadeGroup/VBoxContainer/CountdownWrapper/CountdownLabel.text = "Starting!"
	$UIFadeGroup/VBoxContainer/CountdownWrapper/CountdownAnimator.play("CountdownPulse")
	await get_tree().create_timer(0.5).timeout

	await fade_out_ui()
	start_story_scene()

func fade_out_ui():
	print(">> Fading out UI...")
	$FadeAnimator.play("FadeUIOut")
	await $FadeAnimator.animation_finished

func start_story_scene():
	print(">> Loading story scene...")

	Global.current_scene_name = "StoryIntro"
	var story_scene = preload("res://UI/UI scenes/StoryIntro.tscn").instantiate()

	var current = get_tree().current_scene
	if current:
		current.queue_free()

	get_tree().get_root().add_child(story_scene)
	get_tree().current_scene = story_scene

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/UI scenes/MainMenu.tscn")

func _on_control_button_pressed() -> void:
	Global.resume_game()
	Global.previous_scene_path = get_tree().current_scene.scene_file_path
	get_tree().change_scene_to_file("res://UI/UI scenes/control.tscn")

func _on_tips_button_pressed() -> void:
	Global.resume_game()
	Global.previous_scene_path = get_tree().current_scene.scene_file_path
	get_tree().change_scene_to_file("res://UI/UI scenes/Tips.tscn")
