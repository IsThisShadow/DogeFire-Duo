extends CharacterBody2D

@export var speed := 80
@export var max_health := 50
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

func take_damage(amount):
	if is_dead:
		return
	
	current_health -= amount
	print("Enemy health:", current_health)
	
	if current_health <= 0:
		die()

func die():
	is_dead = true
	
	# Hide the normal flying sprite
	if $enemy_1_SupportShip:
		$enemy_1_SupportShip.visible = false
	
	# Show the DeathSprite and play the death animation
	if $DeathSprite:
		$DeathSprite.visible = true
	
	if $AnimationPlayer:
		$AnimationPlayer.play("death_enemy_1")

	# After death animation finishes, remove the enemy
	await $AnimationPlayer.animation_finished
	queue_free()

func _on_bullet_timer_timeout() -> void:
	var bullet = bullet_scene.instantiate()
	bullet.position = position
	get_tree().current_scene.add_child(bullet)
