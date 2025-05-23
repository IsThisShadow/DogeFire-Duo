extends Area2D

@export var _speed := 275
@export var _damage := 50

func _physics_process(delta):
	position += Vector2.RIGHT.rotated(rotation) * _speed * delta

func _ready():
	# Bullet doesn't need rotation correction now
	pass

func _on_body_entered(body):
	if body.name == "CharacterBodyP1" or body.name == "CharacterBodyP2":
		if body.has_method("take_damage"):
			body.take_damage(_damage)
		queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
