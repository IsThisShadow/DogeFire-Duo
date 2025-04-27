extends CharacterBody2D

@export var speed := 60
@export var max_health := 40
@export var bullet_damage := 18  # Stronger bullet damage
var is_dead := false
var current_health := max_health

var bullet_scene = preload("res://enemies/Enemy_3_bullet.tscn")  # Make sure path is right!

func _ready():
	current_health = max_health

func _physics_process(delta):
	position.x -= speed * delta

func take_damage(amount: int, shooter_player := 1):
	if is_dead:
		return

	current_health -= amount
	print("Enemy 3 health:", current_health)
	spawn_damage_number(amount)  # Show damage popup!

	if current_health <= 0:
		die(shooter_player)

func die(shooter_player := 1):
	is_dead = true

	if $enemy_3_Fighter:
		$enemy_3_Fighter.visible = false
	if $DeathSprite_EN_3:
		$DeathSprite_EN_3.visible = true
	if $AnimationPlayer_EN_3:
		$AnimationPlayer_EN_3.play("death_enemy_3")

	# Award points
	if shooter_player == 1:
		Global.player1_score += 20  # or whatever you want
	elif shooter_player == 2:
		Global.player2_score += 20

	await $AnimationPlayer_EN_3.animation_finished
	queue_free()

func _on_bullet_timer_timeout() -> void:
	var bullet = bullet_scene.instantiate()
	bullet.position = position
	bullet.damage = bullet_damage
	get_tree().current_scene.add_child(bullet)

func spawn_damage_number(amount: int):
	var label = $DamageLabel  # The red label
	label.text = "-" + str(amount)
	label.modulate = Color(1, 0, 0)  # Make it red
	label.visible = true
	label.position = Vector2(0, -20)

	var tween = get_tree().create_tween()
	tween.tween_property(label, "position", Vector2(0, -50), 0.3)  # Fast move up
	tween.tween_property(label, "modulate:a", 0, 0.3)  # Fade out
	await tween.finished

	label.visible = false
	label.modulate.a = 1.0
	label.position = Vector2(0, -20)
