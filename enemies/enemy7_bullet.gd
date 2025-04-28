extends Area2D

@export var speed := 500
@export var damage := 50

func _ready():
	rotation_degrees += 180  # 💥 Correct starting rotation if needed

func _physics_process(delta):
	position += Vector2.RIGHT.rotated(rotation) * speed * delta

func _on_body_entered(body):
	if body.name == "CharacterBodyP1" or body.name == "CharacterBodyP2":
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()

func _on_screen_exited():
	queue_free()
