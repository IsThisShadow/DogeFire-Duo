extends Control


func _on_play_again_pressed() -> void:
	get_tree().change_scene_to_file("res://MainMenu.tscn")


func _on_see_your_score_pressed() -> void:
	print("Show score logic goes here.")
