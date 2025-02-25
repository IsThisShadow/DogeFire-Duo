extends Area2D

var speed := 200
var time := 0.0
var pivot_position := Vector2(0, 0)
var bullet = preload("res://Enemies/enemy_bullet_2.tscn")
var can_shoot = false
# Random vertical movement variables
var vertical_speed := 0.0  # Vertical speed component (randomly changes)
var timer := 0.0  # Timer to track when to change vertical direction

func _ready():
	$Timer.start(2.0)
	pivot_position = position
	
func _physics_process(delta: float) -> void:
	move_ship(delta)
	timer += delta

	if can_shoot:
		shoot()
		$Timer.start(randi() % 5 +1)
		can_shoot = false
		
# Function to move the ship left while adding random vertical movement
func move_ship(delta) -> void:
	position.x -= speed * delta  # Always move to the left
	position.y += vertical_speed * delta  # Add random vertical movement


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func shoot():
	var inst = bullet.instantiate()
	
	get_parent().add_child(inst)
	
	inst.global_position = $bullet_pos.global_position
func _on_timer_timeout() -> void:
	can_shoot = true
	$Timer.stop()
