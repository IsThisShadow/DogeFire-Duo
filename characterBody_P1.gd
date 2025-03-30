extends CharacterBody2D
#@onready's
@onready var animationplayer: AnimationPlayer = $Sprite_p1/AnimationPlayer_p1
@onready var progress_bar: ProgressBar = $ReviveZone/ReviveProgressBar
@onready var revive_label: Label = $ReviveLabel
@onready var revive_count_label: Label = $ReviveCountLabel
@onready var death_announcement: Label = get_node("/root/Main/DeathAnnouncement")
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
			#debug print
			print("Overlapping body:", body.name)
			if body.name == "CharacterBodyP2" and is_dead:
				revive_progress += delta
				progress_bar.value = (revive_progress / revive_time) * 100
				#debug print
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
	# premantent death
	if p1_revive >= p1_max_revive:
		is_dead = true
		$CollisionShape2D_p1.disabled = true
		visible = false #hide the player
		set_process(false) #stops _physics_process
		set_physics_process(false)
		#debug print
		print("player permanently dead")
		death_announcement.text = "Player 1 has Died!"
		death_announcement.visible = true
		await get_tree().create_timer(3.0).timeout
		death_announcement.visible  = false
		return
	# normal downed state
	is_dead = true
	$ReviveZone.monitoring = true
	$ReviveZone/ReviveCollision.disabled = false
	animationplayer.play("Death_p1")
	await animationplayer.animation_finished
	animationplayer.stop()
	#once the animation has finished make the player modulate so the other player can revive
	animationplayer.play("reviveNeed_p1")
	#display the label revive
	revive_label.visible = true
	#debug print
	print("Player1 has died!")
#-------------------------------------------------------------------------------
#what happens when the player is revived including what happens to the progress bar.
func revive():
	print(p1_revive)
	is_dead = false
	revive_progress = 0
	progress_bar.visible = false
	revive_label.visible = false 
	$ReviveZone.monitoring = false
	p1_health = p1_maxHealth
	$ReviveZone/ReviveCollision.disabled = true 
	$CollisionShape2D_p1.disabled = false
	#update revive counter
	p1_revive += 1
	if p1_revive >= p1_max_revive:
		revive_count_label.text = "No revives left!"
	else:
		var revives_left = p1_max_revive - p1_revive
		revive_count_label.text = str(revives_left) + " Revives Left"
	revive_count_label.visible = true
	#hide the revives left label after 2 seconds
	await get_tree().create_timer(2.0).timeout
	revive_count_label.visible = false
	
#-----------------------------------------------------------------------------------
func spawn_damage_number(amount: int):
	var dmg_label = preload("res://FloatingText.tscn").instantiate()
	dmg_label.text = "-" + str(amount)
	dmg_label.position = Vector2(-25, -10)  # Offset above player
	dmg_label.rotation_degrees = 270
	add_child(dmg_label)
#-----------------------------------------------------------------------------------
#testing taking damage, reviving, and animations.
func _on_test_area_body_entered(body: Node2D) -> void:
	if body.name == "CharacterBodyP1":
		var damage := 30 #this allows me to dynamically change the damage number while 
		#still having it show up on the pop up label. 
		p1_health -= damage
		body.spawn_damage_number(damage)
		print("player1 HP:", body.p1_health)
#-----------------------------------------------------------
#revive collsision
func _on_revive_zone_body_entered(body: Node2D) -> void:
	if is_dead:
		progress_bar.visible = true
		
	if is_dead and progress_bar.visible:
		#debug printing
		print(revive_progress)
		print("reviving")

#if player leaves the revive area reset the progress bar
func _on_revive_zone_body_exited(body: Node2D) -> void:
	revive_progress = 0
	progress_bar.value = 0
	progress_bar.visible = false
