extends Node2D

var is_two_player_mode := false
var current_level := 2

var level_time := 0.0
const TIME_LIMIT := 30.0
var transitioned := false

# Enemy Spawning
@onready var screen_size = get_viewport_rect().size
var enemy3_scene = preload("res://enemies/Enemy_3.tscn")
var enemy4_scene = preload("res://enemies/Enemy_4.tscn")
@onready var enemy_timer = $EnemySpawnTimer

func set_2_players(enable: bool):
	is_two_player_mode = enable
	print(">> Player mode set to:", is_two_player_mode)
	_setup_players()

func _ready():
	Global.current_scene_name = "mainLvl_%d" % current_level
	print(">> Scene loaded, 2P mode is:", is_two_player_mode)
	_setup_health_bars()
	_set_parallax_speed()
	
	start_enemy_spawning()

func _process(delta):
	if not get_tree().paused and current_level < 5 and not transitioned:
		level_time += delta
		$HUD/LevelProgressBar.max_value = TIME_LIMIT
		$HUD/LevelProgressBar.value = level_time

		if level_time >= TIME_LIMIT:
			transitioned = true
			_show_weapon_unlock_screen(current_level + 1)

	# Update Player 1 Health
	var p1 = get_node_or_null("CharacterBodyP1")
	if p1:
		var p1_health = p1.p1_health
		var p1_max = p1.p1_maxHealth
		$HUD/Control/P1HealthBar.value = p1_health
		$HUD/Control/P1PercentLabel.text = str(int((p1_health / p1_max) * 100)) + "%"
	else:
		$HUD/Control/P1HealthBar.value = 0
		$HUD/Control/P1PercentLabel.text = "0%"

	# Update Player 1 Score
	$HUD/Control/P1ScoreLabel.text = "Score: " + str(Global.player1_score)

	# Update Player 2 (only if two-player mode)
	var p2 = get_node_or_null("CharacterBodyP2")
	if is_two_player_mode and p2:
		var p2_health = p2.p2_health
		var p2_max = p2.p2_maxHealth
		$HUD/Control2/P2HealthBar.value = p2_health
		$HUD/Control2/P2PercentLabel.text = str(int((p2_health / p2_max) * 100)) + "%"
		$HUD/Control2/P2ScoreLabel.text = "Score: " + str(Global.player2_score)
		$HUD/Control2.visible = true
	else:
		$HUD/Control2.visible = false


func _setup_players():
	var p2 = get_node_or_null("CharacterBodyP2")
	if is_two_player_mode and p2:
		print(">> Enabling Player 2")
		p2.visible = true
		p2.set_process(true)
		p2.set_physics_process(true)
		p2.set_process_input(true)
		p2.set_process_unhandled_input(true)
		_set_collision_polygons_enabled(p2, true)
	elif p2:
		print(">> Disabling Player 2")
		p2.visible = false
		p2.set_process(false)
		p2.set_physics_process(false)
		p2.set_process_input(false)
		p2.set_process_unhandled_input(false)
		_set_collision_polygons_enabled(p2, false)

func _setup_health_bars():
	var p1 = get_node_or_null("CharacterBodyP1")
	if p1:
		$HUD/Control.visible = true
		$HUD/Control/P1HealthBar.max_value = p1.p1_maxHealth
		$HUD/Control/P1HealthBar.value = p1.p1_health
	else:
		$HUD/Control/P1HealthBar.max_value = 1
		$HUD/Control/P1HealthBar.value = 0

	var p2 = get_node_or_null("CharacterBodyP2")
	if is_two_player_mode and p2:
		$HUD/Control2.visible = true
		$HUD/Control2/P2HealthBar.max_value = p2.p2_maxHealth
		$HUD/Control2/P2HealthBar.value = p2.p2_health
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

func _on_enemy_spawn_timer_timeout() -> void:
	var enemy_count = 0
	for child in get_children():
		if child.name.begins_with("Enemy"):
			enemy_count += 1

	if enemy_count < 7:
		spawn_enemy_level2()

	# Randomize spawn time slightly
	enemy_timer.wait_time = randf_range(1.5, 3.5)
	enemy_timer.start()

func spawn_enemy_level2():
	var roll = randi() % 100
	
	if roll < 50:
		# 50% chance to spawn arrow formation
		if randf() < 0.5:  # Only allow arrow spawn 50% of the time when picked
			spawn_arrow_formation()
		else:
			# If not, do nothing (skip)
			return
	else:
		# 50% chance spawn one Enemy 4
		var enemy = enemy4_scene.instantiate()
		var y_pos = randf_range(50, screen_size.y - 50)
		enemy.position = Vector2(screen_size.x + 50, y_pos)
		add_child(enemy)

func spawn_arrow_formation():
	var base_y = randf_range(100, screen_size.y - 100)

	# Middle enemy
	var enemy_mid = enemy3_scene.instantiate()
	enemy_mid.position = Vector2(screen_size.x + 50, base_y)
	add_child(enemy_mid)

	# Top enemy
	var enemy_top = enemy3_scene.instantiate()
	enemy_top.position = Vector2(screen_size.x + 30, base_y - 25)
	add_child(enemy_top)

	# Bottom enemy
	var enemy_bot = enemy3_scene.instantiate()
	enemy_bot.position = Vector2(screen_size.x + 30, base_y + 25)
	add_child(enemy_bot)
