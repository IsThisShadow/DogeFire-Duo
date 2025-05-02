extends Control

var p1_ready := false
var p2_ready := false
var countdown_started := false

var joystick_cooldown := 0.25  # Cooldown time in seconds
var joystick_timer := 0.0      # Timer countdown

func _ready():
	# Hide "Ready!" labels at start
	$UIFadeGroup/ReadyWrapperP1/ReadyLabelP1.visible = false
	$UIFadeGroup/ReadyWrapperP2/ReadyLabelP2.visible = false

	# Set red color for P1, blue for P2
	$UIFadeGroup/ReadyWrapperP1/ReadyLabelP1.add_theme_color_override("font_color", Color(1, 0.2, 0.2))  # Red
	$UIFadeGroup/ReadyWrapperP2/ReadyLabelP2.add_theme_color_override("font_color", Color(0.4, 0.6, 1.0))  # Blue

	# Start with flashing "Press Start"
	$UIFadeGroup/VBoxContainer/CountdownWrapper/CountdownLabel.text = "Press Start"
	$UIFadeGroup/VBoxContainer/CountdownWrapper/StartFlasher.play("FlashStart")

	# Set initial button focus
	$UIFadeGroup/VBoxContainer/ControlButton.grab_focus()

func _process(delta):
	if countdown_started:
		return  # Don't allow new inputs once countdown starts

	joystick_timer -= delta  # Decrease timer

	if joystick_timer <= 0.0:
		var move_up = Input.get_action_strength("ui_up")
		var move_down = Input.get_action_strength("ui_down")

		if move_up > 0.5:
			var focused = get_viewport().gui_get_focus_owner()
			var neighbor_path = focused.get_focus_neighbor(SIDE_TOP)
			if neighbor_path:
				var neighbor = focused.get_node(neighbor_path)
				neighbor.grab_focus()
				joystick_timer = joystick_cooldown

		elif move_down > 0.5:
			var focused = get_viewport().gui_get_focus_owner()
			var neighbor_path = focused.get_focus_neighbor(SIDE_BOTTOM)
			if neighbor_path:
				var neighbor = focused.get_node(neighbor_path)
				neighbor.grab_focus()
				joystick_timer = joystick_cooldown

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

	if event.is_action_pressed("p1_up") or event.is_action_pressed("p2_up"):
		var focused = get_viewport().gui_get_focus_owner()
		var neighbor_path = focused.get_focus_neighbor(SIDE_TOP)
		if neighbor_path:
			var neighbor = focused.get_node(neighbor_path)
			neighbor.grab_focus()

	elif event.is_action_pressed("p1_down") or event.is_action_pressed("p2_down"):
		var focused = get_viewport().gui_get_focus_owner()
		var neighbor_path = focused.get_focus_neighbor(SIDE_BOTTOM)
		if neighbor_path:
			var neighbor = focused.get_node(neighbor_path)
			neighbor.grab_focus()

	if event.is_action_pressed("p1_a") or event.is_action_pressed("p2_a"):
		var focused = get_viewport().gui_get_focus_owner()
		if focused and focused is Button:
			focused.emit_signal("pressed")

func start_countdown():
	countdown_started = true
	print(">> Starting countdown!")

	# Stop flashing effect
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
