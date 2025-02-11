extends Area2D

var speed := 200
var time := 0.0
var pivot_position := Vector2(0, 0)

func _ready():
	pivot_position = position

func _physics_process(delta: float) -> void:
	move_ship(delta)
	wavy_movement(delta, 2, 50) # remove this function if you dont want the ship to move in a sin wave

func move_ship(delta)->void:
	position.x -= speed * delta

func wavy_movement(delta, frequency:float, amplitude:float)->void:
	time -= frequency * delta
	position.y = pivot_position.y + sin(time) * amplitude


#remove the ship when it leaves the screen
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
