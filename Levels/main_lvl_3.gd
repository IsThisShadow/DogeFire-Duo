extends Node2D

var is_two_player_mode := false
var current_level := 3

var level_time := 0.0
const TIME_LIMIT := 20.0
var transitioned := false

# Music control
@export var music_start_time := 5.0
@export var music_stop_time := 110.0
@export var fade_in_time := 2.0
@export var music_fade_out_time := 2.0
var fade_timer := 0.0
var music_fade_out_timer := 0.0
var is_fading_out_music := false

# Enemy Spawning
@onready var screen_size = get_viewport_rect().size
var enemy3_scene = preload("res://enemies/enemy scenes/Enemy_3.tscn")
var enemy4_scene = preload("res://enemies/enemy scenes/Enemy_4.tscn")
var enemy5_scene = preload("res://enemies/enemy scenes/Enemy_5.tscn")
@onready var enemy_timer = $EnemySpawnTimer

func set_2_players(enable: bool):
	is_two_player_mode = enable
	print(">> Player mode set to:", is_two_player_mode)
	_setup_players()

func _ready():
	# Sound setup
	$LevelMusic.volume_db = -80
	$LevelMusic.play()
	$SeekDelayTimer.start()
	fade_timer = fade_in_time
	set_process(true)

	Global.current_scene_name = "mainLvl_3"
	Global.weapon_locked_label = $HUD/WeaponLockedLabel
	Global.unlock_weapon(3)
	
	_setup_health_bars()
	_set_parallax_speed()
	start_enemy_spawning()

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

	# Stop if track exceeds custom stop time
	if not is_fading_out_music and $LevelMusic.get_playback_position() >= music_stop_time:
		$LevelMusic.stop()

	# GAME LOGIC
	if not get_tree().paused and current_level < 5 and not transitioned:
		level_time += delta
		$HUD/LevelProgressBar.max_value = TIME_LIMIT
		$HUD/LevelProgressBar.value = level_time

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

	# Safely check if Player 2 exists
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

func _on_enemy_spawn_timer_timeout() -> void:
	var enemy_count = 0
	for child in get_children():
		if child.name.begins_with("Enemy"):
			enemy_count += 1

	if enemy_count < 7:
		spawn_enemy_level3()

	enemy_timer.wait_time = randf_range(3.5, 5.0)
	enemy_timer.start()

func spawn_enemy_level3():
	var roll = randi() % 100

	if roll < 40:
		spawn_arrow_formation()
	elif roll < 75:
		var enemy = enemy4_scene.instantiate()
		var y_pos = randf_range(50, screen_size.y - 50)
		enemy.position = Vector2(screen_size.x + 50, y_pos)
		add_child(enemy)
	else:
		var enemy = enemy5_scene.instantiate()
		var y_pos = randf_range(100, screen_size.y - 100)
		enemy.position = Vector2(screen_size.x - 150, y_pos)
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
