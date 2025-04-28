extends Node2D

var is_two_player_mode := false
var current_level := 4  # Level 4

var level_time := 0.0
const TIME_LIMIT := 50.0
var transitioned := false

# Enemy Spawning
@onready var screen_size = get_viewport_rect().size
var enemy6_scene = preload("res://enemies/Enemy_6.tscn")
@onready var enemy_timer = $EnemySpawnTimer

var wave1_spawned := false
var wave2_spawned := false

func set_2_players(enable: bool):
	is_two_player_mode = enable
	print(">> Player mode set to:", is_two_player_mode)
	_setup_players()

func _ready():
	Global.current_scene_name = "mainLvl_4"
	print(">> Scene loaded, 2P mode is:", is_two_player_mode)
	_setup_health_bars()
	_set_parallax_speed()
	start_enemy_spawning()

	# Spawn the first Enemy 6 wave immediately
	spawn_big_enemy6_wave()
	wave1_spawned = true

func _process(delta):
	if not get_tree().paused and current_level < 5 and not transitioned:
		level_time += delta
		$HUD/LevelProgressBar.max_value = TIME_LIMIT
		$HUD/LevelProgressBar.value = level_time

		# Mid-level second wave
		if not wave2_spawned and level_time >= (TIME_LIMIT / 2):
			spawn_big_enemy6_wave()
			wave2_spawned = true

		if level_time >= TIME_LIMIT:
			transitioned = true
			_show_weapon_unlock_screen(current_level + 1)

	# Update health bars
	var p1_health = $CharacterBodyP1.p1_health
	var p1_max = $CharacterBodyP1.p1_maxHealth
	$HUD/Control/P1HealthBar.value = p1_health
	$HUD/Control/P1PercentLabel.text = str(int((p1_health / p1_max) * 100)) + "%"

	if is_two_player_mode:
		var p2_health = $CharacterBodyP2.p2_health
		var p2_max = $CharacterBodyP2.p2_maxHealth
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

func _show_weapon_unlock_screen(next_level: int):
	var unlock_scene = preload("res://Scenes/weapon_unlock_screen.tscn").instantiate()
	unlock_scene.next_level_index = next_level
	unlock_scene.is_two_player_mode = is_two_player_mode
	get_tree().get_root().add_child(unlock_scene)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = unlock_scene

# --- Enemy Spawning System ---

func start_enemy_spawning():
	enemy_timer.start()

func _on_enemy_spawn_timer_timeout():
	# Here later we will add random enemy4 / enemy7 spawning
	pass

func spawn_big_enemy6_wave():
	var count := 8  # Number of enemies in the curve
	var spacing: float = (screen_size.y - 150.0) / float(count - 1)

	for i in range(count):
		var enemy = enemy6_scene.instantiate()
		var y_offset = 75 + (spacing * i)  # keep margin at top/bottom
		var curve_amount = sin(float(i) / count * PI) * 100  # create soft curve shape

		enemy.position = Vector2(screen_size.x + 50 + curve_amount, y_offset)
		add_child(enemy)
