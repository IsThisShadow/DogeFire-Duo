extends CharacterBody2D

@export var speed := 80
@export var wave_amplitude := 40  # How tall the sine wave is
@export var wave_frequency := 2.0  # How fast it moves up/down
@export var max_health := 30
@export var bullet_damage := 10  # Same as Enemy 1
var is_dead = false
var _current_health = max_health
@onready var visibility_notifier = $VisibleOnScreenNotifier2D
var bullet_scene = preload("res://enemies/enemy scenes/Enemy_1_bullet.tscn")  # Use enemy 1 bullet

var time_passed := 0.0  # For wave movement

func _ready():
	_current_health = max_health
	$BulletTimer.wait_time = 2.8
	$BulletTimer.start()
	visibility_notifier.connect("screen_exited", Callable(self, "_on_visibility_screen_exited"))

func _physics_process(delta):
	if is_dead:
		return

	time_passed += delta
	position.x -= speed * delta  # Move left across the screen
	position.y += sin(time_passed * wave_frequency) * wave_amplitude * delta  # Wavy vertical motion

func take_damage(amount: int, shooter_player := 1):
	if is_dead:
		return

	_current_health -= amount
	spawn_damage_number(amount)

	if _current_health <= 0:
		die(shooter_player)

func die(shooter_player := 1):
	is_dead = true

	if $enemy_6_Scout_BigWave:
		$enemy_6_Scout_BigWave.visible = false
	if $DeathSprite_EN_6:
		$DeathSprite_EN_6.visible = true
	if $AnimationPlayer_EN_6:
		$AnimationPlayer_EN_6.play("death_enemy_6")

	if shooter_player == 1:
		Global.player1_score += 20
	elif shooter_player == 2:
		Global.player2_score += 20

	await $AnimationPlayer_EN_6.animation_finished
	queue_free()

func _on_bullet_timer_timeout() -> void:
	var bullet = bullet_scene.instantiate()
	bullet.position = position
	bullet._damage = bullet_damage
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


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	Global.player1_score -= 50  # Subtract 50 points when escaping
	queue_free()
