extends Control

var p1_ready := false
var p2_ready := false
var is_two_player_mode := false
var countdown_started := false

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

func _process(delta):
	if countdown_started:
		return  # Don't allow new inputs once countdown starts

	if Input.is_action_just_pressed("p1_start") and not p1_ready:
		p1_ready = true
		$UIFadeGroup/ReadyWrapperP1/ReadyLabelP1.visible = true
		$UIFadeGroup/ReadyWrapperP1/ReadyAnimatorP1.play("ZoomIn")
		print("P1 is ready!")

	if is_two_player_mode:
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

	# Set global values for pause system and scene tracking
	Global.is_two_player_mode = is_two_player_mode
	Global.current_scene_name = "StoryIntro"

	var story_scene = preload("res://StoryIntro.tscn").instantiate()
	story_scene.is_two_player_mode = is_two_player_mode

	var current = get_tree().current_scene
	if current:
		current.queue_free()

	get_tree().get_root().add_child(story_scene)
	get_tree().current_scene = story_scene

func _on_quit_button_pressed() -> void:
	get_tree().quit()
