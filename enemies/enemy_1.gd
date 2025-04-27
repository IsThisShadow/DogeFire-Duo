extends CharacterBody2D

@export var speed = 100

func _physics_process(delta):
	position.x -= speed * delta
