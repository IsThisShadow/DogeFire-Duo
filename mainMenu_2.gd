extends Control

var p1_ready := false
var p2_ready := false
var is_two_player_mode := false
var countdown_started := false

func _ready():
	# Hide "Ready!" labels at start
	$ReadyWrapperP1/ReadyLabelP1.visible = false
	$ReadyWrapperP2/ReadyLabelP2.visible = false

	# Set red color for P1, blue for P2
	$ReadyWrapperP1/ReadyLabelP1.add_theme_color_override("font_color", Color(1, 0.2, 0.2))  # Red
	$ReadyWrapperP2/ReadyLabelP2.add_theme_color_override("font_color", Color(0.4, 0.6, 1.0))  # Blue

	# Set initial label text
	$VBoxContainer/CountdownWrapper/CountdownLabel.text = "Press Start"

func _process(delta):
	if countdown_started:
		return  # Don't allow new inputs once countdown starts

	if Input.is_action_just_pressed("p1_start") and not p1_ready:
		p1_ready = true
		$ReadyWrapperP1/ReadyLabelP1.visible = true
		$ReadyWrapperP1/ReadyAnimatorP1.play("ZoomIn")
		print("P1 is ready!")

	if is_two_player_mode:
		if Input.is_action_just_pressed("p2_start") and not p2_ready:
			p2_ready = true
			$ReadyWrapperP2/ReadyLabelP2.visible = true
			$ReadyWrapperP2/ReadyAnimatorP2.play("ZoomIn")
			print("P2 is ready!")

		if p1_ready and p2_ready:
			start_countdown()
	else:
		if p1_ready:
			start_countdown()

func start_countdown():
	countdown_started = true
	print(">> Starting countdown!")
	await countdown()

func countdown():
	for i in range(5, 0, -1):
		$VBoxContainer/CountdownWrapper/CountdownLabel.text = str(i)
		$VBoxContainer/CountdownWrapper/CountdownAnimator.play("CountdownPulse")
		await get_tree().create_timer(1.0).timeout

	$VBoxContainer/CountdownWrapper/CountdownLabel.text = "Starting!"
	$VBoxContainer/CountdownWrapper/CountdownAnimator.play("CountdownPulse")
	await get_tree().create_timer(0.5).timeout
	start_game()

func start_game():
	print("Both players ready! Starting game...")

	var scene_path = "res://scripts/PlayerScripts/Levels/mainLvl_1.tscn"
	var packed_scene = load(scene_path)

	if packed_scene:
		var game_scene = packed_scene.instantiate()
		game_scene.set_2_players(is_two_player_mode)

		var current = get_tree().current_scene
		if current:
			current.queue_free()

		get_tree().get_root().add_child(game_scene)
		get_tree().current_scene = game_scene
	else:
		print("Failed to load scene:", scene_path)
