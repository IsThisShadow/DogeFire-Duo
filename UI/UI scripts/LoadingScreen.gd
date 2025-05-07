extends Control

@export var target_scene_path: String
@onready var animation_player: AnimationPlayer = $LoadingAnimation


func _ready():
	animation_player.play("load")
	animation_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "load":
		get_tree().change_scene_to_file(target_scene_path)
