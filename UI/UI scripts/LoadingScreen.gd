extends Control

@onready var animation_player: AnimationPlayer = $LoadingAnimation

func _ready():
	animation_player.play("load")
	animation_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "load" and Global.next_scene_after_loading != "":
		get_tree().change_scene_to_file(Global.next_scene_after_loading)
