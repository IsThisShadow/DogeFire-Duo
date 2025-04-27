extends CharacterBody2D

@export var speed = 70  # Maybe slightly slower
@export var max_health = 80  # More health
var is_dead = false
var current_health = max_health
var bullet_scene = preload("res://enemies/Enemy_1_bullet.tscn")
@export var bullet_damage = 15  # Bullet does more damage!

func _ready():
	current_health = max_health

func _physics_process(delta):
	position.x -= speed * delta

func take_damage(amount):
	if is_dead:
		return
	
	current_health -= amount
	print("Enemy_2 health:", current_health)
	if current_health <= 0:
		die()

func die():
	is_dead = true
	if $enemy_2_Scout:
		$enemy_2_Scout.visible = false
	if $DeathSprite_EN_2:
		$DeathSprite_EN_2.visible = true
	if $AnimationPlayer_EN_2:
		$AnimationPlayer_EN_2.play("death_enemy_2")
	await $AnimationPlayer_EN_2.animation_finished
	queue_free()

func _on_bullet_timer_timeout() -> void:
	var bullet = bullet_scene.instantiate()
	bullet.position = position
	bullet.damage = bullet_damage  # SET IT withhout checking
	get_tree().current_scene.add_child(bullet)
