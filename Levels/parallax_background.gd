extends ParallaxBackground

var scroll_speed := 50.0
var speed_increment := 2.0
var time_elapsed := 0.0
var next_increase_time := 10.0

func set_speed(level: int):
	scroll_speed = 50.0 + (level - 1) * 25.0

func _process(delta):
	scroll_offset.x -= scroll_speed * delta

	time_elapsed += delta
	if time_elapsed >= next_increase_time:
		scroll_speed += speed_increment
		next_increase_time += 10.0
