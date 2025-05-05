extends CharacterBody2D

@export var move_speed := 200
@export var stop_x_ratio := 0.75
@export var max_health := 400
@export var tilt_speed := 20.0  # How fast it tilts toward player
@export var bullet_damage := 20
@export var fire_rate := 2.0  # Seconds between bursts

var _current_health = max_health
var is_dead = false
var moving_in = true
var stop_x = 0.0
var bullet_scene = preload("res://enemies/enemy scenes/Enemy_8_bullet.tscn")
var time_since_last_shot := 0.0

func _ready():
	_current_health = max_health
	stop_x = get_viewport_rect().size.x * stop_x_ratio
	$BulletTimer.wait_time = fire_rate
	$BulletTimer.timeout.connect(_on_BulletTimer_timeout)
	$BulletTimer.start()
	$HealthBar.max_value = max_health
	$HealthBar.value = _current_health

func _physics_process(delta):
	if is_dead:
		return

	if moving_in:
		position.x -= move_speed * delta
		if position.x <= stop_x:
			moving_in = false
	else:
		_update_tilt_toward_player(delta)

func _update_tilt_toward_player(delta):
	var player = get_nearest_player()
	if player:
		var direction = (player.global_position - global_position).normalized()
		var target_angle = direction.angle() + PI  # Add 180 degrees in radians
		rotation = lerp_angle(rotation, target_angle, tilt_speed * delta)


func get_nearest_player():
	var p1 = get_node_or_null("/root/MainLvl_5/CharacterBodyP1")
	var p2 = get_node_or_null("/root/MainLvl_5/CharacterBodyP2")
	var players = []
	if p1:
		players.append(p1)
	if p2:
		players.append(p2)

	if players.is_empty():
		return null

	var nearest = players[0]
	var nearest_dist = position.distance_to(nearest.position)

	for player in players:
		var dist = position.distance_to(player.position)
		if dist < nearest_dist:
			nearest = player
			nearest_dist = dist

	return nearest

func fire_laser_burst():
	for i in range(3):
		await get_tree().create_timer(0.1 * i).timeout
		var bullet = bullet_scene.instantiate()
		# Offset to spawn bullet from the front of Enemy 8
		var offset = Vector2(-50, 0).rotated(rotation)
		bullet.global_position = global_position + offset
		bullet.rotation = rotation
		bullet._damage = bullet_damage
		get_tree().current_scene.add_child(bullet)


func _on_BulletTimer_timeout():
	if is_dead:
		return
	fire_laser_burst()

func take_damage(amount: int, shooter_player := 1):
	if is_dead:
		return

	_current_health -= amount
	$HealthBar.value = _current_health
	spawn_damage_number(amount)

	if _current_health <= 0:
		die(shooter_player)

func die(shooter_player := 1):
	is_dead = true
	$BulletTimer.stop()

	if $DeathSprite_EN_8:
		$DeathSprite_EN_8.visible = true
	if $AnimationPlayer_EN_8:
		$AnimationPlayer_EN_8.play("death_enemy_8")

	if shooter_player == 1:
		Global.player1_score += 500
	elif shooter_player == 2:
		Global.player2_score += 500

	await $AnimationPlayer_EN_8.animation_finished
	queue_free()

func spawn_damage_number(amount: int):
	var label = $DamageLabel
	label.text = "-" + str(amount)
	label.modulate = Color(1, 0, 0)
	label.visible = true
	label.position = Vector2(0, -20)

	var tween = get_tree().create_tween()
	tween.tween_property(label, "position", Vector2(0, -50), 0.3)
	tween.tween_property(label, "modulate:a", 0, 0.3)
	await tween.finished

	label.visible = false
	label.modulate.a = 1.0
	label.position = Vector2(0, -20)

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
