extends Area2D

var direction: Vector2 = Vector2(1, 0)
const SPEED := 300

func _physics_process(delta):
	global_position += direction.normalized() * SPEED * delta

func _on_body_entered(body):
	if body.is_in_group("enemies"):
		body.queue_free()  # Remove enemy

		# Play explosion animation
		var anim_player = $Sprite2D/AnimationPlayer
		anim_player.play("explode")  # Make sure this matches your animation name exactly
		$CollisionShape2D.disabled = true  # Disable collisions while animating

		await anim_player.animation_finished
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
