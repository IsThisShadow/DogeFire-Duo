extends Node2D

var bullet_scene = preload("res://Scenes/Bullet2.tscn")
@onready var shoot_point = $ShootPoint
@onready var player_id := 1
var can_shoot := true
var cooldown := 0.2  # Faster fire rate than weapon 1

func fire():
	if not can_shoot:
		return

	can_shoot = false

	var bullet = bullet_scene.instantiate()
	bullet.shooter_player = player_id
	bullet.global_position = shoot_point.global_position
	bullet.direction = Vector2(1, 0)
	get_tree().current_scene.add_child(bullet)

	await get_tree().create_timer(cooldown).timeout
	can_shoot = true

func initialize(owner_player_id: int):
	player_id = owner_player_id
