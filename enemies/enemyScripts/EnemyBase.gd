class_name EnemyBase
extends CharacterBody2D

var _current_health := 100
var is_dead := false

func take_damage(amount: int, shooter_player := 1) -> void:
	if is_dead:
		return

	_current_health -= amount

	# Safe dynamic call to child’s visual method
	if "spawn_damage_number" in self:
		call_deferred("spawn_damage_number",amount)

	if _current_health <= 0:
		die(shooter_player)

func die(shooter_player := 1) -> void:
	assert(false, "Child class must override die() method")
