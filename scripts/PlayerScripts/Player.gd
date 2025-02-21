extends CharacterBody2D

var bullet_scene = preload("res://Scenes/bullet.tscn")
@onready var is_reloading = false
@onready var shooty_part = $ShootPoint

func _physics_process(delta):
	look_at(get_global_mouse_position())

	if Input.is_action_just_pressed("shoot"):
		var bullet = bullet_scene.instantiate()
		bullet.global_position = shooty_part.global_position
		bullet.direction = (get_global_mouse_position() - global_position).normalized()
		$/root/Main.add_child(bullet)

	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
	
		if collision.get_collider().is_in_group("enemies") and not is_reloading:
			is_reloading = true
			get_tree().reload_current_scene()
	
