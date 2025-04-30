extends Area2D

@export var speed = 300
@export var damage := 10

func _physics_process(delta):
	position.x -= speed * delta  # Move the bullet to the left

func _ready():
	rotation_degrees = 270
	if has_node("AnimationPlayer"):
		$AnimationPlayer.play("Enemy1_bullet")

	await get_tree().create_timer(5.0).timeout
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	# If bullet hits Player 1 or Player 2
	if body.name == "CharacterBodyP1" or body.name == "CharacterBodyP2":
		if body.has_method("take_damage"):
			body.take_damage(damage)  # deal 10 damage to player
		queue_free()  # Bullet disappears after hit
