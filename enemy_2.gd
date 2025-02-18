extends Area2D

var speed := 400
var time := 0.0
var pivot_position := Vector2(0, 0)

# Random vertical movement variables
var vertical_speed := 0.0  # Vertical speed component (randomly changes)
var change_direction_time := 1.0  # Time in seconds before changing vertical direction
var timer := 0.0  # Timer to track when to change vertical direction

func _ready():
	pass
func _physics_process(delta: float) -> void:
	move_ship(delta)
# Function to move the ship left while adding random vertical movement
func move_ship(delta) -> void:
	position.x -= speed * delta  # Always move to the left

# Function to set a random vertical direction (up or down)
func _set_random_vertical_direction() -> void:
	# Randomly decide the vertical speed (between -1 and 1)
	vertical_speed = randf_range(-1, 1) * speed  # Scale it by speed to make it more noticeable

# Wavy movement (sinusoidal) as before
func wavy_movement(delta, frequency: float, amplitude: float) -> void:
	time -= frequency * delta
	position.y = pivot_position.y + sin(time) * amplitude


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
