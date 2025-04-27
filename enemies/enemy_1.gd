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
