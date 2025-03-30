extends CharacterBody2D
#@onready's
@onready var animationplayer: AnimationPlayer = $Sprite_p1/AnimationPlayer_p1
@onready var progress_bar: ProgressBar = $ReviveZone/ReviveProgressBar
#----------------------------------------------------------------
# Constant variables
const max_speed: int = 200
const acceleration: int = 5
const friction: int = 3
const revive_time := 2.5 #seconds
#-----------------------------------------------------------------
# Normal variables
var p1_health = 100
var p1_maxHealth = 100
var is_dead = false
var p1_max_revive = 3
var p1_revive = 0
var revive_progress := 0.0

#--------------------------------------------------------------------
func _physics_process(delta: float) -> void:
	# Revive logic runs even when dead
	if is_dead:
		var revived = false
		for body in $ReviveZone.get_overlapping_bodies():
			print("Overlapping body:", body.name)
			if body.name == "CharacterBodyP2" and is_dead:
				revive_progress += delta
				progress_bar.value = (revive_progress / revive_time) * 100
				print("Revive progress:", revive_progress)

				if revive_progress >= revive_time:
					revive()
					revived = true
				break
		return  # Prevent movement if dead
	# Normal movement and animations
	var input = Vector2(
		Input.get_action_strength("p1_right") - Input.get_action_strength("p1_left"),
		Input.get_action_strength("p1_down") - Input.get_action_strength("p1_up")
	).normalized()

	if input:
		animationplayer.play("Idle_p1")
	else:
		animationplayer.stop()

	var lerp_weight = delta * (acceleration if input else friction)
	velocity = lerp(velocity, input * max_speed, lerp_weight)
	move_and_slide()

	# Trigger death
	if p1_health <= 0 and not is_dead:
		die()
		$ReviveZone.monitoring = true
		$ReviveZone/ReviveCollision.disabled = false
		$CollisionShape2D_p1.disabled = true
#-----------------------------------------------------------------------------
# Call this when player dies
func die():
	is_dead = true
	$ReviveZone.monitoring = true
	$ReviveZone/ReviveCollision.disabled = false
	animationplayer.play("Death_p1")
	await animationplayer.animation_finished
	animationplayer.stop()
	#once the animation has finished make the player modulate so the other player can revive
	animationplayer.play("reviveNeed_p1")
	print("Player1 has died!")
#-------------------------------------------------------------------------------
#what happens when the player is revived including what happens to the progress bar.
func revive():
	is_dead = false
	revive_progress = 0
	progress_bar.visible = false
	$ReviveZone.monitoring = false
	p1_health = p1_maxHealth
	$ReviveZone/ReviveCollision.disabled = true 
	$CollisionShape2D_p1.disabled = false
#-----------------------------------------------------------------------------------
#testing taking damage, reviving, and animations.
func _on_test_area_body_entered(_body: Node2D) -> void:
	p1_health -= 50
	print(p1_health)
#-----------------------------------------------------------
#revive collsision
func _on_revive_zone_body_entered(body: Node2D) -> void:
	if is_dead:
		progress_bar.visible = true
		
	if is_dead and progress_bar.visible:
		print(revive_progress)
		print("reviving")

#if player leaves the revive area
func _on_revive_zone_body_exited(body: Node2D) -> void:
	revive_progress = 0
	progress_bar.value = 0
	progress_bar.visible = false
