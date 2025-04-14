extends Area2D

func _ready():
	pass  # Can add idle animations later

func _on_body_entered(body):
	# Optional: play explosion, flash, etc.
	print("hit")
	#queue_free()
	if body.has_method("take_damage"):
		body.take_damage(50)
