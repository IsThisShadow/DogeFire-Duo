extends CharacterBody2D

@onready var animationplayer: AnimationPlayer = $Sprite_p2/AnimationPlayer_p2
@onready var progress_bar: ProgressBar = $ReviveZone_p2/ReviveProgressBar_p2
@onready var revive_label: Label = $ReviveLabel_p2
@onready var revive_count_label: Label = $ReviveCountLabel_p2
@onready var weapon_container: Node2D = $WeaponContainer

var death_announcement: Label = null

var selected_weapon_id := 0
var weapon_scenes = {
	1: preload("res://Scenes/Weapon1.tscn"),
	2: preload("res://Scenes/Weapon2.tscn"),
	3: preload("res://Scenes/Weapon3.tscn"),
	4: preload("res://Scenes/Weapon4.tscn"),
	5: preload("res://Scenes/Weapon5.tscn")
}
var current_weapon = null

const max_speed := 250
const acceleration := 5
const friction := 3
const revive_time := 2.5

var p2_health := 100
var p2_maxHealth = 100
var is_dead = false
var p2_max_revive = 3
var p2_revive = 0
var revive_progress := 0.0
var is_invincible := false

func _ready():
	$Sprite_p2.modulate = Color(0.5, 0.5, 1.2)
	death_announcement = get_tree().get_first_node_in_group("death_announcement")

	# Load stats from global
	p2_health = Global.player2_health
	p2_revive = Global.player2_revives

func _physics_process(delta):
	if is_dead:
		if $ReviveZone_p2.monitoring:
			for body in $ReviveZone_p2.get_overlapping_bodies():
				if body.name == "CharacterBodyP1":
					revive_progress += delta
					progress_bar.value = (revive_progress / revive_time) * 100
					if revive_progress >= revive_time:
						revive()
					break
		return

	var input = Vector2(
		Input.get_action_strength("p2_right") - Input.get_action_strength("p2_left"),
		Input.get_action_strength("p2_down") - Input.get_action_strength("p2_up")
	).normalized()

	if input:
		animationplayer.play("Idle_p2")
	else:
		animationplayer.stop()

	var lerp_weight = delta * (acceleration if input else friction)
	velocity = lerp(velocity, input * max_speed, lerp_weight)
	move_and_slide()

	var screen_size = get_viewport_rect().size
	var margin := 10.0
	position.x = clamp(position.x, margin, screen_size.x - margin)
	position.y = clamp(position.y, margin, screen_size.y - margin)

	if p2_health <= 0 and not is_dead:
		die()

	if Input.is_action_just_pressed("p2_b"):
		select_weapon(1)
	elif Input.is_action_just_pressed("p2_l1"):
		select_weapon(2)
	elif Input.is_action_just_pressed("p2_l2"):
		select_weapon(3)
	elif Input.is_action_just_pressed("p2_r1"):
		select_weapon(4)
	elif Input.is_action_just_pressed("p2_r2"):
		select_weapon(5)

	if Input.is_action_just_pressed("p2_a") and current_weapon:
		current_weapon.fire()

func select_weapon(id: int):
	if selected_weapon_id == id:
		return
	selected_weapon_id = id
	if current_weapon:
		current_weapon.queue_free()
	var weapon_scene = weapon_scenes.get(id)
	if weapon_scene:
		current_weapon = weapon_scene.instantiate()
		weapon_container.add_child(current_weapon)

func die():
	is_dead = true
	progress_bar.visible = false
	if p2_revive >= p2_max_revive:
		$CollisionShape2D_p2.disabled = true
		animationplayer.play("PermaDeath")
		await animationplayer.animation_finished
		set_physics_process(false)
		set_process(false)
		visible = false

		if death_announcement:
			death_announcement.text = "Player 2 has Died!"
			death_announcement.visible = true
			await get_tree().create_timer(2.0).timeout
			death_announcement.visible = false
		return

	$ReviveZone_p2.monitoring = true
	$ReviveZone_p2/ReviveCollision_p2.disabled = false
	$CollisionShape2D_p2.disabled = true

	animationplayer.play("death_p2")
	await animationplayer.animation_finished

	animationplayer.stop()
	animationplayer.play("reviveNeed_p2")

	revive_label.visible = true
	print("Player 2 is dead. Showing revive UI.")

func revive():
	is_dead = false
	revive_progress = 0
	progress_bar.visible = false
	revive_label.visible = false
	p2_health = p2_maxHealth

	is_invincible = true
	animationplayer.play("reviveNeed_p2")
	print("Revive animation playing for P2.")

	while $ReviveZone_p2.get_overlapping_bodies().size() > 0:
		await get_tree().process_frame

	$CollisionShape2D_p2.disabled = false
	$ReviveZone_p2.monitoring = false
	$ReviveZone_p2/ReviveCollision_p2.disabled = true

	await get_tree().create_timer(2.0).timeout
	is_invincible = false

	p2_revive += 1
	revive_count_label.text = "No revives left!" if p2_revive >= p2_max_revive else str(p2_max_revive - p2_revive) + " Revives Left"
	revive_count_label.visible = true
	await get_tree().create_timer(2.0).timeout
	revive_count_label.visible = false

	# Save updated stats
	Global.player2_health = p2_health
	Global.player2_revives = p2_revive
	
func take_damage(amount: int):
	if not is_dead and not is_invincible:
		p2_health -= amount
		Global.player2_health = p2_health  # Save to global
		spawn_damage_number(amount)
		flash_red()

func spawn_damage_number(amount: int):
	var dmg_label = preload("res://FloatingText.tscn").instantiate()
	dmg_label.text = "-" + str(amount)
	dmg_label.position = Vector2(-25, -10)
	dmg_label.rotation_degrees = 270
	add_child(dmg_label)

func flash_red():
	var original_pos = position
	$Sprite_p2.modulate = Color(1, 0.3, 0.3)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", original_pos + Vector2(6, -4), 0.04)
	tween.tween_property(self, "position", original_pos - Vector2(-6, 4), 0.04)
	tween.tween_property(self, "position", original_pos, 0.03)
	await tween.finished
	$Sprite_p2.modulate = Color(1, 1, 1)

func _on_test_area_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(50)

func _on_revive_zone_body_entered(body: Node2D) -> void:
	if is_dead:
		progress_bar.visible = true
		print("P2 Revive Started: P1 entered the zone.")

func _on_revive_zone_body_exited(body: Node2D) -> void:
	if is_dead and body.name == "CharacterBodyP1":
		revive_progress = 0
		progress_bar.value = 0
		progress_bar.visible = false
		print("P2 Revive Cancelled: P1 left the zone.")
