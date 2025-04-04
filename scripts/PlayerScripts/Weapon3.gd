extends CharacterBody2D

var bullet_scene = preload("res://Scenes/Bullets/Laserbullet.tscn")
@onready var shooty_part = $ShootPoint

# Fire rate control variables
var fire_rate = 0.005  # Fire rate (time between shots in seconds)
var can_shoot = true  # Whether the player can shoot or not
var reload_timer : Timer  # Declare the timer variable

# Initialize reload timer
func _ready():
	reload_timer = Timer.new()
	reload_timer.wait_time = fire_rate
	reload_timer.one_shot = true
	reload_timer.autostart = false
	add_child(reload_timer)
	reload_timer.connect("timeout", Callable(self, "_on_reload_timeout"))

func _physics_process(delta):
	# Make sure the character always faces right
	look_at(global_position + Vector2(1, 0))

	# Shooting logic with fire rate control while holding down the shoot button
	if Input.is_action_pressed("shoot") and can_shoot:
		# Create the bullet and set its properties
		var bullet = bullet_scene.instantiate()
		bullet.global_position = shooty_part.global_position
		bullet.direction = Vector2(1, 0)  # Rightward direction (positive x-axis)

		# Add the bullet to the scene
		get_tree().current_scene.add_child(bullet)

		# Start reload (fire rate)
		can_shoot = false
		reload_timer.start()  # Start the reload timer

# Called when the reload timer finishes
func _on_reload_timeout():
	can_shoot = true
