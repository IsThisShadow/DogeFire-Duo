extends Control


func _on_back_button_pressed() -> void:
	if Global.previous_scene_path != "":
		var scene_res = load(Global.previous_scene_path)
		if scene_res:
			var scene = scene_res.instantiate()
			get_tree().current_scene.queue_free()
			get_tree().get_root().add_child(scene)
			get_tree().current_scene = scene
			Global.previous_scene_path = ""
		else:
			print("Error: Could not load scene from path:", Global.previous_scene_path)
	else:
		print("Error: No previous scene path set.")
