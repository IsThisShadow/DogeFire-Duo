extends Control

func _on_button_pressed() -> void:
	if Global.previous_scene_path != "":
		var scene = load(Global.previous_scene_path).instantiate()
		get_tree().current_scene.queue_free()
		get_tree().get_root().add_child(scene)
		get_tree().current_scene = scene
		Global.previous_scene_path = ""
