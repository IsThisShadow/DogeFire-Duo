extends CharacterBody2D

var direction: Vector2 = Vector2.ZERO

@export var speed: int = 400

func _process(_delta):
	direction = Input.get_vector("p1_left","p1_right","p1_up","p1_down")
func _physics_process(_delta):
	velocity = direction * 400
	move_and_slide()
