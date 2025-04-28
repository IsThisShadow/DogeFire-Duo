extends CharacterBody2D

@export var speed := 100
@export var max_health := 400
@export var bullet_damage := 20

var is_dead = false
var current_health = max_health
@onready var visibility_notifier = $VisibleOnScreenNotifier2D
var bullet_scene = preload("res://enemies/Enemy_8_bullet.tscn")

func _ready():
	current_health = max_health
	$BulletTimer.wait_time = 2.5
	$BulletTimer.start()
	visibility_notifier.connect("screen_exited", Callable(self, "_on_visibility_screen_exited"))

func _physics_process(delta):
	if is_dead:
		return

	# Smooth left movement + slight vertical tilt
	position.x -= speed * delta
	position.y += sin(position.x / 40.0) * 2.0

	# Health bar update
	$HealthBar.max_value = max_health
	$HealthBar.value = current_health

func _on_bullet_timer_timeout():
	var bullet = bullet_scene.instantiate()
	bullet.position = position
	bullet.damage = bullet_damage
	get_tree().current_scene.add_child(bullet)

func take_damage(amount: int, shooter_player := 1):
	if is_dead:
		return

	current_health -= amount
	spawn_damage_number(amount)

	if current_health <= 0:
		die(shooter_player)

func die(shooter_player := 1):
	is_dead = true

	if $enemy_8_Dreadnought:
		$enemy_8_Dreadnought.visible = false
	if $DeathSprite_EN_8:
		$DeathSprite_EN_8.visible = true
	if $AnimationPlayer_EN_8:
		$AnimationPlayer_EN_8.play("death_enemy_8")

	if shooter_player == 1:
		Global.player1_score += 100
	elif shooter_player == 2:
		Global.player2_score += 100

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


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
