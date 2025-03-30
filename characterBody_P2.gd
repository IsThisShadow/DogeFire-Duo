extends CharacterBody2D

@onready var animationplayer: AnimationPlayer = $Sprite_p2/AnimationPlayer_p2

# Constant variables
const max_speed: int = 200
const acceleration: int = 5
const friction: int = 3

# Normal variables
var p2_health = 100
var p2_maxHealth = 100
var p2_is_dead = false
var p2_max_revive = 3
var p2_revive = 0

func _physics_process(delta: float) -> void:
	if p2_is_dead:
		return
	
	var input = Vector2(
		Input.get_action_strength("p2_right") - Input.get_action_strength("p2_left"),
		Input.get_action_strength("p2_down") - Input.get_action_strength("p2_up")
	).normalized()

	# IDLE and movement animation
	if input:
		animationplayer.play("Idle_p2")
	else:
		animationplayer.stop()

	var lerp_weight = delta * (acceleration if input else friction)
	velocity = lerp(velocity, input * max_speed, lerp_weight)
	move_and_slide()
	#call the death function when the hp is low.
	if p2_health <=0:
		die_p2()
# Call this when player dies
func die_p2():
	p2_is_dead = true
	animationplayer.play("death_p2")
	await animationplayer.animation_finished
	animationplayer.stop()
	
