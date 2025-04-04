extends CharacterBody2D

var bullet_scene = preload("res://Scenes/bullet.tscn")
@onready var is_reloading = false
@onready var shooty_part = $ShootPoint

func _physics_process(delta):
	# Make sure the character always faces right
	look_at(global_position + Vector2(1, 0))

	if Input.is_action_just_pressed("shoot"):
		var bullet = bullet_scene.instantiate()
		bullet.global_position = shooty_part.global_position
		
		# Always shoot to the right
		bullet.direction = Vector2(1, 0)  # Rightward direction (positive x-axis)
		$/root/Main.add_child(bullet)

	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
	
		if collision.get_collider().is_in_group("enemies") and not is_reloading:
			is_reloading = true
			get_tree().reload_current_scene()
