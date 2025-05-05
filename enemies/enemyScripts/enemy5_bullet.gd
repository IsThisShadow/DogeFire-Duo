extends Area2D

@export var _speed := 250
@export var _damage := 25

func _ready():
	_initialize_bullet()


func _initialize_bullet():
	rotation_degrees = 270
	if has_node("AnimationPlayer"):
		$AnimationPlayer.play("Enemy5_bullet")
	await get_tree().create_timer(5.0).timeout
	queue_free()
	
	
func _physics_process(delta):
	position.x -= _speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.name == "CharacterBodyP1" or body.name == "CharacterBodyP2":
		if body.has_method("take_damage"):
			body.take_damage(_damage)
		queue_free()
