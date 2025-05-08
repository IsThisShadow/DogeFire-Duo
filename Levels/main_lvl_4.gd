extends Node2D

var is_two_player_mode := false
var current_level := 4

var level_time := 0.0
const TIME_LIMIT := 20.0
var transitioned := false

# Music control
@export var music_start_time := 80.0
@export var music_stop_time := 200.0
@export var fade_in_time := 1.5
@export var music_fade_out_time := 2.0

var fade_timer := 0.0
var music_fade_out_timer := 0.0
var is_fading_out_music := false

# Enemy Spawning
@onready var screen_size = get_viewport_rect().size
var enemy1_scene = preload("res://enemies/enemy scenes/Enemy_1.tscn")
var enemy3_scene = preload("res://enemies/enemy scenes/Enemy_3.tscn")
var enemy4_scene = preload("res://enemies/enemy scenes/Enemy_4.tscn")
var enemy6_scene = preload("res://enemies/enemy scenes/Enemy_6.tscn")
var enemy7_scene = preload("res://enemies/enemy scenes/Enemy_7.tscn")
@onready var enemy_timer = $EnemySpawnTimer

var wave1_spawned := false
var miniboss_spawned := false
var wave2_spawned := false

func set_2_players(enable: bool):
	is_two_player_mode = enable
	print(">> Player mode set to:", is_two_player_mode)
	_setup_players()

func _ready():
	# Music init
	$LevelMusic.volume_db = -80
	$LevelMusic.play()
	$SeekDelayTimer.start()
	fade_timer = fade_in_time
	set_process(true)

	Global.current_scene_name = "mainLvl_4"
	Global.weapon_locked_label = $HUD/WeaponLockedLabel
	Global.unlock_weapon(4)
	
	_setup_health_bars()
	_set_parallax_speed()
	start_enemy_spawning()

	spawn_big_enemy6_wave()
	wave1_spawned = true

func _process(delta):
	# MUSIC FADE-IN
	if fade_timer > 0:
		fade_timer -= delta
		var t = 1.0 - fade_timer / fade_in_time
		$LevelMusic.volume_db = lerp(-30, 0, t)

	# MUSIC FADE-OUT
	if is_fading_out_music:
		music_fade_out_timer -= delta
		var t = clamp(music_fade_out_timer / music_fade_out_time, 0, 1)
		$LevelMusic.volume_db = lerp(0, -30, 1.0 - t)
		if music_fade_out_timer <= 0:
			$LevelMusic.stop()
			is_fading_out_music = false
			_show_weapon_unlock_screen(current_level + 1)

	# Stop if track hits limit (not fading out)
	if not is_fading_out_music and $LevelMusic.get_playback_position() >= music_stop_time:
		$LevelMusic.stop()

	if not get_tree().paused and current_level < 5 and not transitioned:
		level_time += delta
		$HUD/LevelProgressBar.max_value = TIME_LIMIT
		$HUD/LevelProgressBar.value = level_time

		if not miniboss_spawned and level_time >= (TIME_LIMIT * 0.4):
			spawn_enemy7_miniboss()
			miniboss_spawned = true

		if not wave2_spawned and level_time >= (TIME_LIMIT * 0.5):
			spawn_big_enemy6_wave()
			wave2_spawned = true

		if level_time >= TIME_LIMIT:
			transitioned = true
			is_fading_out_music = true
			music_fade_out_timer = music_fade_out_time

	# Safely check if Player 1 exists
	var p1 = get_node_or_null("CharacterBodyP1")
	if p1:
		var p1_health = p1.p1_health
		var p1_max = p1.p1_maxHealth
		$HUD/Control/P1HealthBar.value = p1_health
		$HUD/Control/P1PercentLabel.text = str(int((p1_health)))
		$HUD/Control/P1ScoreLabel.text = "Score: " + str(Global.player1_score)
		$HUD/Control/WeaponLabel_P1.text = "Weapon: " + $CharacterBodyP1.get_weapon_name()
		$HUD/Control2/WeaponLabel_P2.text = "weapon: " + $CharacterBodyP2.get_weapon_name()
	else:
		$HUD/Control.visible = false

	var p2 = get_node_or_null("CharacterBodyP2")
	if is_two_player_mode and p2:
		var p2_health = p2.p2_health
		var p2_max = p2.p2_maxHealth
		$HUD/Control2/P2HealthBar.value = p2_health
		$HUD/Control2/P2PercentLabel.text = str(int((p2_health)))
		$HUD/Control2/P2ScoreLabel.text = "Score: " + str(Global.player2_score)
		$HUD/Control/WeaponLabel_P1.text = "Weapon: " + $CharacterBodyP1.get_weapon_name()
		$HUD/Control2/WeaponLabel_P2.text = "weapon: " + $CharacterBodyP2.get_weapon_name()
		$HUD/Control2.visible = true
	else:
		$HUD/Control2.visible = false

func _on_seek_delay_timer_timeout() -> void:
	if $LevelMusic.playing:
		$LevelMusic.seek(music_start_time)
	$SeekDelayTimer.stop()

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

# --- Enemy Spawning System ---

func start_enemy_spawning():
	enemy_timer.start()

func _on_enemy_spawn_timer_timeout():
	if wave1_spawned and not miniboss_spawned:
		if randi() % 100 < 70:
			spawn_random_enemy1()
		if randi() % 100 < 50:
			spawn_random_enemy4()
	elif wave2_spawned:
		if randi() % 100 < 80:
			spawn_random_enemy1()
		if randi() % 100 < 80:
			spawn_random_enemy4()

	enemy_timer.wait_time = randf_range(2.0, 3.5)
	enemy_timer.start()

func spawn_big_enemy6_wave():
	var count := 8
	var spacing: float = (screen_size.y - 150.0) / float(count - 1)

	for i in range(count):
		var enemy = enemy6_scene.instantiate()
		var y_offset = 75 + (spacing * i)
		var curve_amount = sin(float(i) / count * PI) * 100

		enemy.position = Vector2(screen_size.x + 50 + curve_amount, y_offset)
		add_child(enemy)

func spawn_enemy7_miniboss():
	var miniboss = enemy7_scene.instantiate()
	var y_pos = screen_size.y / 2
	miniboss.position = Vector2(screen_size.x + 100, y_pos)
	add_child(miniboss)

func spawn_random_enemy1():
	var enemy = enemy1_scene.instantiate()
	var y_pos = randf_range(50, screen_size.y - 50)
	enemy.position = Vector2(screen_size.x + 50, y_pos)
	add_child(enemy)

func spawn_random_enemy4():
	var enemy = enemy4_scene.instantiate()
	var y_pos = randf_range(50, screen_size.y - 50)
	enemy.position = Vector2(screen_size.x + 50, y_pos)
	add_child(enemy)

func spawn_random_enemy1_or_enemy4():
	var roll = randi() % 100
	if roll < 50:
		spawn_random_enemy1()
	else:
		spawn_random_enemy4()
