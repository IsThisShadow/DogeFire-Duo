extends CharacterBody2D

@export var speed := 80  # Leftward movement speed
@export var vertical_speed := 40  # Vertical move speed
@export var move_range := 120  # Up/down range (made a little smaller)
@export var max_health := 80
@export var bullet_damage := 30
@export var stop_x_position := 950  # X where enemy stops

var is_dead = false
var current_health = max_health
var moving_left = true
var base_y = 0
var moving_up = true

var top_margin := 80  # <-- Stay at least 80px from top
var bottom_margin := 80  # <-- Stay at least 80px from bottom

var bullet_scene = preload("res://enemies/enemy scenes/Enemy_5_bullet.tscn")

func _ready():
	current_health = max_health
	base_y = position.y
	$BulletTimer.wait_time = 2.8
	$BulletTimer.start()
	$VisibleOnScreenNotifier2D.connect("screen_exited", Callable(self, "_on_screen_exited"))
func _physics_process(delta):
	if moving_left:
		position.x -= speed * delta
		if position.x <= stop_x_position:
			moving_left = false
	else:
		# Only vertical movement now
		if moving_up:
			position.y -= vertical_speed * delta
			if position.y < clamp(base_y - move_range, top_margin, get_viewport_rect().size.y - bottom_margin):
				moving_up = false
		else:
			position.y += vertical_speed * delta
			if position.y > clamp(base_y + move_range, top_margin, get_viewport_rect().size.y - bottom_margin):
				moving_up = true

func take_damage(amount: int, shooter_player := 1):
	if is_dead:
		return

	current_health -= amount
	spawn_damage_number(amount)

	if current_health <= 0:
		die(shooter_player)

func die(shooter_player := 1):
	is_dead = true

	if $enemy_5_Torpedo:
		$enemy_5_Torpedo.visible = false
	if $DeathSprite_EN_5:
		$DeathSprite_EN_5.visible = true
	if $AnimationPlayer_EN_5:
		$AnimationPlayer_EN_5.play("death_enemy_5")

	if shooter_player == 1:
		Global.player1_score += 50
	elif shooter_player == 2:
		Global.player2_score += 50

	await $AnimationPlayer_EN_5.animation_finished
	queue_free()

func _on_bullet_timer_timeout() -> void:
	var bullet = bullet_scene.instantiate()
	bullet.position = position
	bullet.damage = bullet_damage
	get_tree().current_scene.add_child(bullet)

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
