extends Area2D
@export var damage := 10 
var direction: Vector2 = Vector2(1, 0)
const SPEED := 400  # Adjust per weapon style

func _physics_process(delta):
	global_position += direction.normalized() * SPEED * delta

func _on_body_entered(body):
	if body.is_in_group("enemies"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		if area.has_method("take_damage"):
			area.take_damage(damage)
			area.queue_free()  # Or call take_damage() if your enemies use health
			queue_free()  # Destroy the bullet too
