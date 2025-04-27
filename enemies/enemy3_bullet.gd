extends Area2D


@export var speed := 300
@export var damage := 15  # Slightly more damage than Enemy 1 bullet!

func _physics_process(delta):
	position.x -= speed * delta

func _ready():
	rotation_degrees = 270
	if has_node("AnimationPlayer"):
		$AnimationPlayer.play("Enemy34_bullet")  # (Or the new animation name)

	await get_tree().create_timer(5.0).timeout
	queue_free()
	

func _on_body_entered(body: Node2D) -> void:
	if body.name == "CharacterBodyP1" or body.name == "CharacterBodyP2":
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()
