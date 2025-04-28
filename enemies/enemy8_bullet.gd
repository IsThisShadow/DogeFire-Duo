extends Area2D

@export var speed := 400
@export var damage := 20

func _ready():
	$AnimationPlayer.play("Enemy8_bullet")  # Make sure this matches your animation name!

func _physics_process(delta):
	position.x -= speed * delta  # Laser moves left across screen

	# If offscreen, delete it (optional if you add VisibilityNotifier2D)
	if position.x < -100:
		queue_free()
		
func _on_body_entered(body):
	if body.name == "CharacterBodyP1" or body.name == "CharacterBodyP2":
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()

func _on_screen_exited():
	queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	pass # Replace with function body.
