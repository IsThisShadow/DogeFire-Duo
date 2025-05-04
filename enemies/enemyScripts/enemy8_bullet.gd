extends Area2D

@export var _speed := 300
@export var _damage := 20

var velocity := Vector2.ZERO

func _ready():
	$AnimationPlayer.play("Enemy8_bullet")
	call_deferred("_calculate_velocity")

func _calculate_velocity():
	velocity = Vector2.LEFT.rotated(rotation) * _speed
	print("Deferred Rotation:", rotation, " Velocity:", velocity)

func _physics_process(delta):
	position += velocity * delta
	if position.x < -100 or position.x > get_viewport_rect().size.x + 100 \
	or position.y < -100 or position.y > get_viewport_rect().size.y + 100:
		queue_free()

func _on_body_entered(body):
	if body.name == "CharacterBodyP1" or body.name == "CharacterBodyP2":
		if body.has_method("take_damage"):
			body.take_damage(_damage)
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
