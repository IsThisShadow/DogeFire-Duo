extends Area2D

var direction: Vector2 = Vector2(1, 0)
const SPEED := 400  # Adjust per weapon style
@export var shooter_player:= 1
@export var damage: int = 15

func _physics_process(delta):
	global_position += direction.normalized() * SPEED * delta

func _on_body_entered(body):
	if body.is_in_group("enemies"):
		if body is EnemyBase:
			body.take_damage(damage, shooter_player)
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
