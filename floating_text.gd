extends Label

var float_distance := 30
var float_duration := 0.8

func _ready():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position:y", position.y - float_distance, float_duration)
	tween.tween_property(self, "modulate:a", 0.0, float_duration)
	tween.tween_callback(queue_free)
