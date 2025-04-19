extends Control

var p1_ready := false
var p2_ready := false
var countdown_started := false
var is_two_player_mode := false
var next_level_index := 1  # Set this appropriately before this screen loads

func _ready():
	
	Global.current_scene_name = "weapon_unlock_screen"
	Global.is_two_player_mode = is_two_player_mode
	set_process_input(true)  #  Needed to use _input()

	# Hide "Ready" labels initially
	$UIBox/ReadyWrapperP1/Player1ReadyLabel.visible = false
	$UIBox/ReadyWrapperP2/Player2ReadyLabel.visible = false

	# Set colors (red for P1, blue for P2)
	$UIBox/ReadyWrapperP1/Player1ReadyLabel.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
	$UIBox/ReadyWrapperP2/Player2ReadyLabel.add_theme_color_override("font_color", Color(0.4, 0.6, 1.0))

	# Start flashing prompt
	$UIBox/wrapperContinue/CountdownLabel.text = "Press Start"
	$UIBox/wrapperContinue/AnimationPlayer.play("FlashStart")

	_show_weapon_info()

func _input(event):
	if countdown_started:
		return

	if event.is_action_pressed("p1_x") or event.is_action_pressed("p2_x"):
		Global.toggle_pause_menu()

func _process(delta):
	if countdown_started:
		return

	if Input.is_action_just_pressed("p1_start") and not p1_ready:
		p1_ready = true
		$UIBox/ReadyWrapperP1/Player1ReadyLabel.visible = true
		$UIBox/ReadyWrapperP1/AnimationPlayer.play("ZoomIn")

	if is_two_player_mode:
		if Input.is_action_just_pressed("p2_start") and not p2_ready:
			p2_ready = true
			$UIBox/ReadyWrapperP2/Player2ReadyLabel.visible = true
			$UIBox/ReadyWrapperP2/AnimationPlayer.play("ZoomIn")

		if p1_ready and p2_ready:
			start_countdown()
	else:
		if p1_ready:
			start_countdown()

func start_countdown():
	countdown_started = true

	$UIBox/wrapperContinue/AnimationPlayer.stop()
	$UIBox/wrapperContinue/CountdownLabel.modulate.a = 1.0

	await get_tree().create_timer(0.5).timeout
	$UIBox/wrapperContinue/CountdownLabel.text = "READY!"

	await get_tree().create_timer(0.5).timeout
	load_next_level()

func load_next_level():
	Global.current_scene_name = "mainLvl_%d" % next_level_index
	Global.is_two_player_mode = is_two_player_mode

	var next_scene_path = "res://scripts/PlayerScripts/Levels/mainLvl_%d.tscn" % next_level_index
	var next_scene = load(next_scene_path).instantiate()
	next_scene.set_2_players(is_two_player_mode)

	var current = get_tree().current_scene
	if current:
		current.queue_free()

	get_tree().get_root().add_child(next_scene)
	get_tree().current_scene = next_scene

func _show_weapon_info():
	var weapon_name_label = $UIBox/wrapperWeapon/weaponNameLabel
	var next_level_label = $UIBox/wrapperNextLevel/nextLevelLabel
	var equip_info_label = $UIBox/wrapperEquip/equipInfoLabel

	match next_level_index:
		2:
			weapon_name_label.text = "Weapon 3 - Laser Cannon"
			next_level_label.text = "Next: Entering Level 2"
			equip_info_label.text = "Press 'L2' to equip this weapon in-game"
		3:
			weapon_name_label.text = "Weapon 4 - Plasma Beam"
			next_level_label.text = "Next: Entering Level 3"
			equip_info_label.text = "Press 'R1' to equip this weapon in-game"
		4:
			weapon_name_label.text = "Weapon 5 - Omega Blaster"
			next_level_label.text = "Next: Entering Level 4"
			equip_info_label.text = "Press 'R2' to equip this weapon in-game"
		5:
			weapon_name_label.text = "ALL Weapons Unlocked!"
			next_level_label.text = "Next: Entering Final Level"
			equip_info_label.text = "Use 1-5 keys to switch between all weapons"
		_:
			weapon_name_label.text = "New Weapon Unlocked!"
			next_level_label.text = "Next Level Incoming..."
			equip_info_label.text = ""
