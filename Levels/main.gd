extends Node2D

@export var enemy_scenes: Array[PackedScene] = []

@onready var timer = $EnemySpawnTimer
@onready var enemy_container = $EnemyContainer
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_enemy_spawn_timer_timeout() -> void:
	var e = enemy_scenes.pick_random().instantiate()
	e.global_position = Vector2(1500, 500)
	enemy_container.add_child(e)
