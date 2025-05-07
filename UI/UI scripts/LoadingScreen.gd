extends Control

@export var target_scene_path: String
@onready var loading_animation: AnimatedSprite2D = $LoadingAnimation

func _ready():
	loading_animation.play("load")
	# Wait for the animation to finish, then transition
	await loading_animation.animation_finished
	get_tree().change_scene_to_file(target_scene_path)
