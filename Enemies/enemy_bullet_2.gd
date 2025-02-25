extends AnimatedSprite2D

func _process(delta):
	translate(Vector2(-1,0) * 1000 * delta)


func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	queue_free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player_One":
		set_process(false)
		
		body.take_damage()
		
		await get_tree().create_timer(0.2).timeout
		
		queue_free()
