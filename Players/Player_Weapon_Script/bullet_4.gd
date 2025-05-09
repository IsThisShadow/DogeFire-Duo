extends Area2D
@export var damage := 10
var direction: Vector2 = Vector2(1, 0)
const SPEED := 400  # Adjust per weapon style
@export var shooter_player:= 1
func _physics_process(delta):
	global_position += direction.normalized() * SPEED * delta

func _on_body_entered(body):
	if body.is_in_group("enemies"):
		if body.has_method("take_damage"):
			body.take_damage(damage, shooter_player)
			
		if body.has_method("is_dead") and body.is_dead():
			if shooter_player == 1:
				Global.p1_kills += 1
			elif shooter_player == 2:
				Global.p2_kills += 1
		queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
