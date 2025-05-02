extends Node2D

var is_two_player_mode := false
var current_level := 5

var level_time := 0.0
const TIME_LIMIT := 10.0
var transitioned := false

# Enemy Spawning
@onready var screen_size = get_viewport_rect().size
var enemy1_scene = preload("res://enemies/enemy scenes/Enemy_1.tscn")
var enemy2_scene = preload("res://enemies/enemy scenes/Enemy_2.tscn")
var enemy3_scene = preload("res://enemies/enemy scenes/Enemy_3.tscn")
var enemy4_scene = preload("res://enemies/enemy scenes/Enemy_4.tscn")
var enemy5_scene = preload("res://enemies/enemy scenes/Enemy_5.tscn")
var enemy6_scene = preload("res://enemies/enemy scenes/Enemy_6.tscn")
var enemy8_scene = preload("res://enemies/enemy scenes/Enemy_8.tscn")
@onready var enemy_timer = $EnemySpawnTimer

var wave2_spawned := false
var boss_spawned := false
var big_enemy6_wave_count := 0

func set_2_players(enable: bool):
	is_two_player_mode = enable
	_setup_players()

func _ready():
	Global.current_scene_name = "mainLvl_5"
	_setup_health_bars()
	_set_parallax_speed()
	start_enemy_spawning()

func _process(delta):
	if not get_tree().paused and not transitioned:
		level_time += delta
		$HUD/LevelProgressBar.max_value = TIME_LIMIT
		$HUD/LevelProgressBar.value = level_time

		if not wave2_spawned and level_time >= (TIME_LIMIT * 0.4):
			wave2_spawned = true

		if not boss_spawned and level_time >= (TIME_LIMIT * 0.6):
			spawn_enemy8_boss()
			boss_spawned = true

		if level_time >= TIME_LIMIT:
			transitioned = true
			_show_win_screen()

	_update_player_hud()

func _update_player_hud():
	var p1 = get_node_or_null("CharacterBodyP1")
	if p1:
		$HUD/Control/P1HealthBar.value = p1.p1_health
		$HUD/Control/P1PercentLabel.text = str(int((p1.p1_health / p1.p1_maxHealth) * 100)) + "%"
	else:
		$HUD/Control.visible = false

	var p2 = get_node_or_null("CharacterBodyP2")
	if is_two_player_mode and p2:
		$HUD/Control2/P2HealthBar.value = p2.p2_health
		$HUD/Control2/P2PercentLabel.text = str(int((p2.p2_health / p2.p2_maxHealth) * 100)) + "%"
		$HUD/Control/P1ScoreLabel.text = "Score: " + str(Global.player1_score)
		$HUD/Control/WeaponLabel_P1.text = "Weapon: " + $CharacterBodyP1.get_weapon_name()
		$HUD/Control2/WeaponLabel_P2.text = "weapon: " + $CharacterBodyP2.get_weapon_name()
		$HUD/Control2.visible = true
	else:
		$HUD/Control2.visible = false

func _setup_players():
	if is_two_player_mode:
		$CharacterBodyP2.visible = true
		$CharacterBodyP2.set_physics_process(true)
		$CharacterBodyP2.set_process(true)
		_set_collision_polygons_enabled($CharacterBodyP2, true)
	else:
		$CharacterBodyP2.visible = false
		$CharacterBodyP2.set_physics_process(false)
		$CharacterBodyP2.set_process(false)
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
	await get_tree().create_timer(1.0).timeout
	var win_scene = preload("res://UI/UI scenes/WinScreen.tscn").instantiate()
	get_tree().get_root().add_child(win_scene)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = win_scene

# --- Enemy Spawning System ---

func start_enemy_spawning():
	enemy_timer.start()

func _on_enemy_spawn_timer_timeout() -> void:
	var enemy_count = 0
	for child in get_children():
		if child.name.begins_with("Enemy"):
			enemy_count += 1

	if enemy_count < 8:
		if not wave2_spawned:
			spawn_random_enemy1_to_4()
		else:
			spawn_random_enemy1_to_6()

	# Randomly spawn big enemy6 waves a few times
	if big_enemy6_wave_count < 3 and randi() % 100 < 20:
		spawn_big_enemy6_wave()
		big_enemy6_wave_count += 1

	enemy_timer.wait_time = randf_range(2.5, 4.0)
	enemy_timer.start()

func spawn_random_enemy1_to_4():
	var roll = randi() % 100
	if roll < 30:
		spawn_enemy1()
	elif roll < 60:
		spawn_enemy2()
	elif roll < 80:
		spawn_arrow_formation()
	else:
		spawn_enemy4()

func spawn_random_enemy1_to_6():
	var roll = randi() % 100
	if roll < 20:
		spawn_enemy1()
	elif roll < 40:
		spawn_enemy2()
	elif roll < 60:
		spawn_arrow_formation()
	elif roll < 75:
		spawn_enemy4()
	elif roll < 90:
		spawn_enemy5()
	else:
		spawn_enemy6()

func spawn_enemy1():
	var enemy = enemy1_scene.instantiate()
	enemy.position = Vector2(screen_size.x + 50, randf_range(50, screen_size.y - 50))
	add_child(enemy)

func spawn_enemy2():
	var enemy = enemy2_scene.instantiate()
	enemy.position = Vector2(screen_size.x + 50, randf_range(50, screen_size.y - 50))
	add_child(enemy)

func spawn_arrow_formation():
	var base_y = randf_range(100, screen_size.y - 100)

	var enemy_mid = enemy3_scene.instantiate()
	enemy_mid.position = Vector2(screen_size.x + 50, base_y)
	add_child(enemy_mid)

	var enemy_top = enemy3_scene.instantiate()
	enemy_top.position = Vector2(screen_size.x + 30, base_y - 25)
	add_child(enemy_top)

	var enemy_bot = enemy3_scene.instantiate()
	enemy_bot.position = Vector2(screen_size.x + 30, base_y + 25)
	add_child(enemy_bot)

func spawn_enemy4():
	var enemy = enemy4_scene.instantiate()
	enemy.position = Vector2(screen_size.x + 50, randf_range(50, screen_size.y - 50))
	add_child(enemy)

func spawn_enemy5():
	var enemy = enemy5_scene.instantiate()
	enemy.position = Vector2(screen_size.x - randf_range(200, 250), randf_range(50, screen_size.y - 50))
	add_child(enemy)

func spawn_enemy6():
	var enemy = enemy6_scene.instantiate()
	enemy.position = Vector2(screen_size.x + 50, randf_range(50, screen_size.y - 50))
	add_child(enemy)

func spawn_enemy8_boss():
	var boss = enemy8_scene.instantiate()
	boss.position = Vector2(screen_size.x + 200, screen_size.y / 2)
	add_child(boss)

func spawn_big_enemy6_wave():
	var count := 8
	var spacing: float = (screen_size.y - 150.0) / float(count - 1)
	for i in range(count):
		var enemy = enemy6_scene.instantiate()
		var y_offset = 75 + (spacing * i)
		var curve_amount = sin(float(i) / count * PI) * 100
		enemy.position = Vector2(screen_size.x + 50 + curve_amount, y_offset)
		add_child(enemy)
