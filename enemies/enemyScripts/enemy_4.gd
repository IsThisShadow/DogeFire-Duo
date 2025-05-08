extends CharacterBody2D

@export var speed := 50
@export var max_health := 50
@export var bullet_damage := 18  # Same stronger bullet as Enemy 3
var is_dead := false
var _current_health = max_health

var bullet_scene = preload("res://enemies/enemy scenes/Enemy_3_bullet.tscn")  # SAME bullet as enemy 3

func _ready():
	_current_health = max_health
	$BulletTimer.wait_time = 2.5
	$BulletTimer.start()

func _physics_process(delta):
	position.x -= speed * delta

	# Check if enemy goes off the left side of the screen
	if position.x < -100 and not is_dead:
		apply_penalty()
		queue_free()

func take_damage(amount: int, shooter_player := 1):
	if is_dead:
		return

	_current_health -= amount
	spawn_damage_number(amount)

	if _current_health <= 0:
		die(shooter_player)

func die(shooter_player := 1):
	is_dead = true

	# Make sure the normal flying sprite hides immediately
	if $enemy_4_Bomber:
		$enemy_4_Bomber.visible = false

	# Show death sprite before animation plays
	if $DeathSprite_EN_4:
		$DeathSprite_EN_4.visible = true

	# Now safely play death animation
	if $AnimationPlayer_EN_4:
		$AnimationPlayer_EN_4.play("death_enemy_4")

	# Award points
	if shooter_player == 1:
		Global.player1_score += 25
	elif shooter_player == 2:
		Global.player2_score += 25

	await $AnimationPlayer_EN_4.animation_finished
	queue_free()

func _on_bullet_timer_timeout() -> void:
	var bullet = bullet_scene.instantiate()
	bullet.position = position
	bullet._damage = bullet_damage
	get_tree().current_scene.add_child(bullet)

func spawn_damage_number(amount: int):
	var label = $DamageLabel
	label.text = "-" + str(amount)
	label.modulate = Color(1, 0, 0)  # Red popup
	label.visible = true
	label.position = Vector2(0, -20)

	var tween = get_tree().create_tween()
	tween.tween_property(label, "position", Vector2(0, -50), 0.3)
	tween.tween_property(label, "modulate:a", 0, 0.3)
	await tween.finished

	label.visible = false
	label.modulate.a = 1.0
	label.position = Vector2(0, -20)

func apply_penalty():
	if Global.is_two_player_mode:
		Global.player1_score = max(Global.player1_score - 10, 0)
		Global.player2_score = max(Global.player2_score - 10, 0)
	else:
		Global.player1_score = max(Global.player1_score - 10, 0)
