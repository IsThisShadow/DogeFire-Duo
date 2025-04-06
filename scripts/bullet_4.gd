extends Area2D

var direction: Vector2 = Vector2(1, 0)
const SPEED := 400  # Adjust per weapon style

func _physics_process(delta):
	global_position += direction.normalized() * SPEED * delta

func _on_body_entered(body: Node):
	if body.is_in_group("enemies"):
		body.queue_free()  # Or call take_damage() if your enemies use health
		queue_free()  # Destroy the bullet too

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
