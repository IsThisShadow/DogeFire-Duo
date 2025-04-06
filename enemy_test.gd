extends Area2D

func _ready():
	pass  # Can add idle animations later

func _on_body_entered(_body):
	# Optional: play explosion, flash, etc.
	print("hit")
	queue_free()
