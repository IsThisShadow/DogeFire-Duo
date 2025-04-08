extends ParallaxBackground


# Scroll speed in pixels per second
var scroll_speed := 100.0

# Optional: how much the scroll speed increases over time
var speed_increment := 2.0
var time_elapsed := 0.0
var next_increase_time := 10.0 
 

func _process(delta):
	# Move the background left by increasing the scroll_offset.x
	scroll_offset.x -= scroll_speed * delta

	# Gradually increase the scroll speed (optional)
	time_elapsed += delta
	if time_elapsed >= next_increase_time:
		scroll_speed += speed_increment
		next_increase_time += 10.0  # wait another 10 seconds before next increase
