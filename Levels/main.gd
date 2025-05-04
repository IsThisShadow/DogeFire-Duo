extends Node2D

var is_two_player_mode := false
var current_level := 1  # Set this to 1, 2, 3, 4, or 5 depending on the scene

var level_time := 0.0
const TIME_LIMIT := 20.0
const ENEMY_SPAWN_MARGIN = 50
var transitioned := false

# Enemy spawning setup
@onready var screen_size = get_viewport_rect().size
var enemy1_scene = preload("res://enemies/enemy scenes/Enemy_1.tscn")
var enemy2_scene = preload("res://enemies/enemy scenes/Enemy_2.tscn")
@onready var enemy_timer = $Enemy1SpawnTimer
@onready var weapon_locked_label: Label = $HUD/WeaponLockedLabel

func set_2_players(enable: bool):
	is_two_player_mode = enable
	print(">> Player mode set to:", is_two_player_mode)
	_setup_players()

func _ready():
	Global.current_scene_name = "mainLvl_%d" % current_level
	Global.weapon_locked_label = $HUD/WeaponLockedLabel
	Global.unlock_weapon(0) #wepaon 1
	Global.unlock_weapon(1) #wepaon 2
	_setup_players()
	_setup_health_bars()
	_set_parallax_speed()
	if current_level == 1:
		start_enemy_spawning()

func _process(delta):
	# Only accumulate gameplay time while not paused
	if not get_tree().paused and current_level < 5 and not transitioned:
		level_time += delta

		# Update level progress bar dynamically
		$HUD/LevelProgressBar.max_value = TIME_LIMIT
		$HUD/LevelProgressBar.value = level_time

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

	# Update Player Scores
	$HUD/Control/P1ScoreLabel.text = "Score: " + str(Global.player1_score)
	$HUD/Control/WeaponLabel_P1.text = "Weapon: " + $CharacterBodyP1.get_weapon_name()
	$HUD/Control2/WeaponLabel_P2.text = "weapon: " + $CharacterBodyP2.get_weapon_name()
	if is_two_player_mode:
		$HUD/Control/WeaponLabel_P1.text = "Weapon: " + $CharacterBodyP1.get_weapon_name()
		$HUD/Control2/WeaponLabel_P2.text = "weapon: " + $CharacterBodyP2.get_weapon_name()
		$HUD/Control2/P2ScoreLabel.text = "Score: " + str(Global.player2_score)

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
	var unlock_scene = preload("res://UI/UI scenes/weapon_unlock_screen.tscn").instantiate()
	unlock_scene.next_level_index = next_level
	unlock_scene.is_two_player_mode = is_two_player_mode
	get_tree().get_root().add_child(unlock_scene)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = unlock_scene
	


# Enemy Spawning
func start_enemy_spawning():
	enemy_timer.start()

func _on_enemy_1_spawn_timer_timeout() -> void:
	var enemy_count = 0
	for child in get_children():
		if child.name.begins_with("Enemy"):
			enemy_count += 1

	if enemy_count < 5:
		spawn_enemy()

	# Randomize next spawn time
	enemy_timer.wait_time = randf_range(1.5, 3.5)
	enemy_timer.start()

func spawn_enemy():
	var roll = randi() % 100  # Random number between 0-99
	var enemy
	
	if roll < 65:
		enemy = enemy1_scene.instantiate()
	else:
		enemy = enemy2_scene.instantiate()

	var y_pos = randf_range(ENEMY_SPAWN_MARGIN, screen_size.y - ENEMY_SPAWN_MARGIN)
	enemy.position = Vector2(screen_size.x + 50, y_pos)
	add_child(enemy)
