extends CharacterBody2D

@export var speed = 80
@export var max_health = 50
var is_dead = false
var current_health = max_health
var bullet_scene = preload("res://enemies/Enemy_1_bullet.tscn")

func _physics_process(delta):
	position.x -= speed * delta

func _ready():
	current_health = max_health
	
func take_damage(amount):
	if is_dead:
		return
	current_health -= amount
	print("Enemy health:", current_health) 
	if current_health <= 0:
		die()
			
			
func die():
	is_dead = true
	
	# Hide the normal idle sprite
	if $enemy_1_SupportShip:
		$enemy_1_SupportShip.visible = false

	# Show the DeathSprite
	if $DeathSprite:
		$DeathSprite.visible = true

	# Play the death animation
	if $AnimationPlayer:
		$AnimationPlayer.play("death_enemy_1")

	# Wait for death animation to finish, then remove enemy
	await $AnimationPlayer.animation_finished
	queue_free()


func _on_bullet_timer_timeout() -> void:
	var bullet = bullet_scene.instantiate()
	bullet.position = position  # Spawn bullet at enemy position
	get_tree().current_scene.add_child(bullet)
