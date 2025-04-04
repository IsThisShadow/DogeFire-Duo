extends Area2D

var direction: Vector2
const SPEED = 10
var explosion_scene = preload("res://Scenes/explosion.tscn")
var is_signal_connected = false  # Boolean flag to track the connection

func _ready():
	# Ensure that this Area2D has a CollisionShape2D
	var collision_shape = $CollisionShape2D
	collision_shape.shape = CircleShape2D.new()  # Example shape, can be modified
	
	# Set the correct collision layer and mask using the new system in Godot 4.3
	collision_layer = 1  # This sets the collision layer of the Area2D
	collision_mask = 2   # This makes it detect collisions with bodies in layer 2 (e.g., "enemies")

func _physics_process(delta: float) -> void:
	# Move the object based on direction and speed
	global_position += direction * SPEED

# This method will be triggered when a body enters the Area2D
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("enemies"):  # Check if the body belongs to the "enemies" group
		# Destroy the enemy body
		body.queue_free()

		# Create an explosion effect
		var explosion = explosion_scene.instantiate()
		explosion.global_position = global_position
		explosion.emitting = true
		explosion.lifetime = randf_range(0.5, 0.7)

		# Add explosion to the scene
		get_tree().root.get_node("Game").add_child(explosion)  # Assuming Game is the root or a valid parent
		queue_free()  # Destroy the Area2D itself after collision
