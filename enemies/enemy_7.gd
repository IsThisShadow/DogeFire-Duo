extends CharacterBody2D

@export var speed := 20  # Slow move speed to the left
@export var rotation_speed := 2.0  # How quickly it rotates towards players
@export var max_health := 350
@export var bullet_damage := 70

@onready var health_bar: ProgressBar = $HealthBar

var can_take_damage: bool = false
var is_dead := false
var current_health = max_health
var has_stopped := false  # New flag!

var bullet_scene = preload("res://enemies/Enemy_7_bullet.tscn")

func _ready():
	health_bar.max_value = max_health
	health_bar.value = max_health
	current_health = max_health
	$BulletTimer.wait_time = 3.5
	$BulletTimer.start()
	rotation_degrees = 180  # Face LEFT
	await get_tree().create_timer(3.0).timeout
	can_take_damage = true

func _physics_process(delta):
	# Only move until reaching halfway
	if not has_stopped:
		position.x -= speed * delta

		if position.x <= get_viewport_rect().size.x / 2:
			has_stopped = true  # Stop moving once halfway

	# Always aim even after stopping
	var target_dir = get_target_direction()
	var desired_angle = target_dir.angle()
	rotation = lerp_angle(rotation, desired_angle, rotation_speed * delta)

func get_target_direction() -> Vector2:
	var p1 = get_node_or_null("/root/MainLvl_4/CharacterBodyP1")
	var p2 = get_node_or_null("/root/MainLvl_4/CharacterBodyP2")
	var closest = null

	if p1 and not p1.is_queued_for_deletion():
		closest = p1
	if p2 and not p2.is_queued_for_deletion():
		if closest == null or position.distance_to(p2.position) < position.distance_to(closest.position):
			closest = p2

	if closest:
		return (closest.global_position - global_position).normalized()
	else:
		return Vector2.LEFT

func take_damage(amount: int, shooter_player := 1):
	if is_dead or not can_take_damage:
		return  # Can't be hurt yet!

	current_health -= amount
	health_bar.value = current_health

	spawn_damage_number(amount)

	if current_health <= 0:
		die(shooter_player)


func die(shooter_player := 1):
	is_dead = true
	health_bar.visible = false 
	if $enemy_7_Battlecruiser:
		$enemy_7_Battlecruiser.visible = false
	if $DeathSprite_EN_7:
		$DeathSprite_EN_7.visible = true
	if $AnimationPlayer_EN_7:
		$AnimationPlayer_EN_7.play("death_enemy_7")

	if shooter_player == 1:
		Global.player1_score += 100
	elif shooter_player == 2:
		Global.player2_score += 100

	await $AnimationPlayer_EN_7.animation_finished
	queue_free()

func _on_bullet_timer_timeout():
	var bullet = bullet_scene.instantiate()
	bullet.global_position = global_position
	bullet.rotation = rotation
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
