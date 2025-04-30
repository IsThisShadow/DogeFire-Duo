extends Node2D

var bullet_scene = preload("res://Players/Player_Weapon_Scenes/Bullet1.tscn")

@onready var shoot_point = $ShootPoint
@onready var player_id := 1
var can_shoot := true
var cooldown := .3 #delay between shots in seconds


func fire():
	print("FIRING: player_id =", player_id)
	if not can_shoot:
		return

	can_shoot = false

	var bullet = bullet_scene.instantiate()
	bullet.shooter_player = player_id
	print("FIRING: player_id =", player_id)
	bullet.global_position = shoot_point.global_position
	bullet.direction = Vector2(1, 0)
	get_tree().current_scene.add_child(bullet)

	# Cooldown before next shot
	await get_tree().create_timer(cooldown).timeout
	can_shoot = true
	
func initialize(owner_player_id: int):
	player_id = owner_player_id

	
	
