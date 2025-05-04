extends CharacterBody2D

@export var speed = 50  # Maybe slightly slower
@export var max_health = 30 # More health
var is_dead = false
var _current_health = max_health
var bullet_scene = preload("res://enemies/enemy scenes/Enemy_1_bullet.tscn")
@export var bullet_damage = 15  # Bullet does more damage!

func _ready():
	_current_health = max_health
	# Check if enemy escaped (x < -buffer)
	if position.x < -50:
		apply_escape_penalty()
		queue_free()

func _physics_process(delta):
	position.x -= speed * delta

func take_damage(amount, shooter_player := 1):
	if is_dead:
		return
	
	_current_health -= amount
	spawn_damage_number(amount)

	if _current_health <= 0:
		die(shooter_player)

func die(shooter_player := 1):
	is_dead = true
	
	if $enemy_2_Scout:
		$enemy_2_Scout.visible = false
	if $DeathSprite_EN_2:
		$DeathSprite_EN_2.visible = true
	if $AnimationPlayer_EN_2:
		$AnimationPlayer_EN_2.play("death_enemy_2")

	# Correctly give points
	if shooter_player == 1:
		Global.player1_score += 30
	elif shooter_player == 2:
		Global.player2_score += 30

	await $AnimationPlayer_EN_2.animation_finished
	queue_free()
	
func _on_bullet_timer_timeout() -> void:
	var bullet = bullet_scene.instantiate()
	bullet.position = position
	bullet._damage = bullet_damage  # SET IT withhout checking
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


func apply_escape_penalty():
	var penalty_amount = 30  # or whatever penalty you want

	if Global.is_single_player:
		Global.player1_score -= penalty_amount
	else:
		Global.player1_score -= penalty_amount
		Global.player2_score -= penalty_amount
