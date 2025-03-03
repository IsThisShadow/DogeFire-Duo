extends Button




func _on_button_up() -> void:
	$"../..".hide()
	#play.visible = true
	get_tree().change_scene_to_file("res://Levels/main.tscn")
