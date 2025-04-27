extends CharacterBody2D

@export var speed := 60
@export var max_health := 20
var current_health := max_health
var is_dead := false

var bullet_scene = preload("res://enemies/Enemy_1_bullet.tscn")  # Make sure this path is correct!

func _ready():
	current_health = max_health
	# Make sure only the normal flying sprite is visible at start
	if $enemy_1_SupportShip:
		$enemy_1_SupportShip.visible = true
	if $DeathSprite:
		$DeathSprite.visible = false

func _physics_process(delta):
	position.x -= speed * delta

func take_damage(amount, shooter_player := 1):
	if is_dead:
		return
	
	current_health -= amount
	spawn_damage_number(amount)
	if current_health <= 0:
		die(shooter_player)

func die(shooter_player := 1):
	is_dead = true
	
	# Hide the idle sprite
	if $enemy_1_SupportShip:
		$enemy_1_SupportShip.visible = false
	if $DeathSprite:
		$DeathSprite.visible = true
	
	# Play death animation
	if $AnimationPlayer:
		$AnimationPlayer.play("death_enemy_1")

	# Give points
	if shooter_player == 1:
		Global.player1_score += 15
	elif shooter_player == 2:
		Global.player2_score += 15

	await $AnimationPlayer.animation_finished
	queue_free()

func _on_bullet_timer_timeout() -> void:
	var bullet = bullet_scene.instantiate()
	bullet.position = position
	get_tree().current_scene.add_child(bullet)

func spawn_damage_number(amount: int):
	var label = $DamageLabel
	label.text = "-" + str(amount)
	label.modulate = Color(1, 0, 0, 1)  # <-- RED color immediately!
	label.visible = true
	label.position = Vector2(0, -20)

	# Animate faster (shorter time)
	var tween = get_tree().create_tween()
	tween.tween_property(label, "position", Vector2(0, -40), 0.2)  # move up quickly
	tween.parallel().tween_property(label, "modulate:a", 0, 0.2)  # fade out quickly
	await tween.finished

	label.visible = false
	label.modulate = Color(1, 1, 1, 1)  # Reset color and alpha
	label.position = Vector2(0, -20)  # Reset position
