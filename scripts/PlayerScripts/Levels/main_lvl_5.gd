extends Node2D

var is_two_player_mode := false
var current_level := 5  # Set this to 1, 2, 3, 4, or 5 depending on the scene

var level_time := 0.0
const TIME_LIMIT := 20.0
var transitioned := false

func set_2_players(enable: bool):
	is_two_player_mode = enable
	print(">> Player mode set to:", is_two_player_mode)
	_setup_players()

func _ready():
	Global.current_scene_name = "mainLvl_5"
	print(">> Scene loaded, 2P mode is:", is_two_player_mode)
	_setup_health_bars()
	_set_parallax_speed()

func _process(delta):
	if not get_tree().paused and not transitioned:
		level_time += delta

		# Update level progress bar dynamically
		$HUD/LevelProgressBar.max_value = TIME_LIMIT
		$HUD/LevelProgressBar.value = level_time
		
		if level_time >= TIME_LIMIT:
			transitioned = true
			_show_win_screen()

	# Safely check if Player 1 exists
	var p1 = get_node_or_null("CharacterBodyP1")
	if p1:
		var p1_health = p1.p1_health
		var p1_max = p1.p1_maxHealth
		$HUD/Control/P1HealthBar.value = p1_health
		$HUD/Control/P1PercentLabel.text = str(int((p1_health / p1_max) * 100)) + "%"
	else:
		$HUD/Control.visible = false

	# Safely check if Player 2 exists
	var p2 = get_node_or_null("CharacterBodyP2")
	if is_two_player_mode and p2:
		var p2_health = p2.p2_health
		var p2_max = p2.p2_maxHealth
		$HUD/Control2/P2HealthBar.value = p2_health
		$HUD/Control2/P2PercentLabel.text = str(int((p2_health / p2_max) * 100)) + "%"
		$HUD/Control2.visible = true
	else:
		$HUD/Control2.visible = false



func _setup_players():
	if is_two_player_mode:
		print(">> Enabling Player 2")
		$CharacterBodyP2.visible = true
		$CharacterBodyP2.set_process(true)
		$CharacterBodyP2.set_physics_process(true)
		$CharacterBodyP2.set_process_input(true)
		$CharacterBodyP2.set_process_unhandled_input(true)
		_set_collision_polygons_enabled($CharacterBodyP2, true)
	else:
		print(">> Disabling Player 2")
		$CharacterBodyP2.visible = false
		$CharacterBodyP2.set_process(false)
		$CharacterBodyP2.set_physics_process(false)
		$CharacterBodyP2.set_process_input(false)
		$CharacterBodyP2.set_process_unhandled_input(false)
		_set_collision_polygons_enabled($CharacterBodyP2, false)

func _setup_health_bars():
	$HUD/Control.visible = true
	$HUD/Control/P1HealthBar.max_value = $CharacterBodyP1.p1_maxHealth
	$HUD/Control/P1HealthBar.value = $CharacterBodyP1.p1_health

	if is_two_player_mode:
		$HUD/Control2.visible = true
		$HUD/Control2/P2HealthBar.max_value = $CharacterBodyP2.p2_maxHealth
		$HUD/Control2/P2HealthBar.value = $CharacterBodyP2.p2_health
	else:
		$HUD/Control2.visible = false

func _set_parallax_speed():
	if $ParallaxBackground.has_method("set_speed"):
		$ParallaxBackground.set_speed(current_level)

func _set_collision_polygons_enabled(node: Node, enabled: bool):
	for child in node.get_children():
		if child is CollisionPolygon2D:
			child.disabled = not enabled
		elif child.get_child_count() > 0:
			_set_collision_polygons_enabled(child, enabled)

func _show_win_screen():
	await get_tree().create_timer(1.0).timeout  # Optional small delay for polish
	var win_scene = preload("res://WinScreen.tscn").instantiate()
	get_tree().get_root().add_child(win_scene)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = win_scene
