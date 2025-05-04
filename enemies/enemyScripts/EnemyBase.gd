class_name EnemyBase

extends CharacterBody2D

var _current_health := 100
var is_dead := false


func take_damage(amount: int, shooter_player := 1) -> void:
	if is_dead:
		return
	_current_health -= amount
	if _current_health <= 0:
		die()

func die():
	assert(false, "Child class must override die() method")
