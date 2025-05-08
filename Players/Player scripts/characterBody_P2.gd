
"""
1. Player 2 health bar's visuals are bugged Just started the game and it was already messed up
2. play again doesnt work after the death screen, after both players die the play again button doesnt work
"""

extends CharacterBody2D

@onready var animationplayer: AnimationPlayer = $Sprite_p2/AnimationPlayer_p2
@onready var progress_bar: ProgressBar = $ReviveZone_p2/ReviveProgressBar_p2
@onready var revive_label: Label = $ReviveLabel_p2
@onready var revive_count_label: Label = $ReviveCountLabel_p2
@onready var weapon_container: Node2D = $WeaponContainer
@onready var revive_timer_label: Label = $ReviveTimerLabelP2

var death_announcement: Label = null

var selected_weapon_id := 0
var weapon_scenes = {
	1: preload("res://Players/Player_Weapon_Scenes/Weapon1.tscn"),
	2: preload("res://Players/Player_Weapon_Scenes/Weapon2.tscn"),
	3: preload("res://Players/Player_Weapon_Scenes/Weapon3.tscn"),
	4: preload("res://Players/Player_Weapon_Scenes/Weapon4.tscn"),
	5: preload("res://Players/Player_Weapon_Scenes/Weapon5.tscn")
}

var weapon_names = {
	1: "Pulse Blaster",
	2: "Laser Storm",
	3: "Rail Gun",
	4: "Dual Shot",
	5: "The Devastator",
}
var current_weapon = null
var default_color := Color(0.5, 0.5, 1.2)
const max_speed := 250
const acceleration := 5
const friction := 3
const revive_time := 2.5
const MAX_REVIVE_TIME := 10.0

var revive_active := false
var is_downed := false
var revive_time_left := 10.0
var is_dead = false
var is_permadead = false
var p2_health := 10
var p2_maxHealth = 100
var p2_max_revive = 3
var p2_revive = 0
var revive_progress := 0.0
var is_invincible := false



func get_weapon_name():
	return weapon_names.get(selected_weapon_id, "No weapon selected")

func _ready():
	# If player 2 was permadead in a previous level, do not spawn
	if Global.player2_permadead:
		queue_free()
		return

	$Sprite_p2.modulate = default_color
	death_announcement = get_tree().get_first_node_in_group("death_announcement")

	# Load stats from global
	p2_health = Global.player2_health
	p2_revive = Global.player2_revives


func _physics_process(delta):
	if not Global.is_two_player_mode:
		return  # Disable Player 2 entirely in single-player mode

	if is_dead:
		if is_downed and revive_active:
			revive_time_left -= delta
			revive_timer_label.text = "Revive in: " + str(int(revive_time_left))

			if revive_time_left <= 4.0:
				var t = int(revive_time_left * 5) % 2
				revive_timer_label.modulate = Color(1, 0.2, 0.2) if t == 0 else Color(1, 1, 1)
			else:
				revive_timer_label.modulate = Color(1, 1, 1)

			if revive_time_left <= 0 and not is_permadead:
				revive_timer_label.visible = false
				revive_active = false
				is_downed = false
				die_for_real()

		if $ReviveZone_p2.monitoring:
			var is_being_revived = false
			for body in $ReviveZone_p2.get_overlapping_bodies():
				if body.name == "CharacterBodyP1":
					is_being_revived = true
					revive_progress += delta
					progress_bar.value = (revive_progress / revive_time) * 100
					if revive_progress >= revive_time:
						revive()
					break
			if is_being_revived:
				revive_active = false
				revive_timer_label.visible = false
			else:
				if not revive_active and not is_permadead:
					start_revive_timer()
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
	if not Global.unlocked_weapons[id - 1]:  # Check unlock state
		Global.show_locked_weapon_warning(id)
		return

	if selected_weapon_id == id:
		return

	selected_weapon_id = id

	var last_fire_time := 0.0
	if current_weapon and current_weapon.has_method("get_last_fire_time"):
		last_fire_time = current_weapon.get_last_fire_time()
		current_weapon.queue_free()

	var weapon_scene = weapon_scenes.get(id)
	if weapon_scene:
		current_weapon = weapon_scene.instantiate()
		current_weapon.initialize(2)  # Player 2 ID

		if current_weapon.has_method("set_last_fire_time"):
			current_weapon.set_last_fire_time(last_fire_time)

		weapon_container.add_child(current_weapon)



func die():
	is_dead = true
	if p2_revive >= p2_max_revive:
		die_for_real()
		return

	$ReviveZone_p2.monitoring = true
	$ReviveZone_p2/ReviveCollision_p2.disabled = false
	$CollisionShape2D_p2.disabled = true

	animationplayer.play("death_p2")
	await animationplayer.animation_finished
	animationplayer.stop()
	animationplayer.play("reviveNeed_p2")

	revive_label.visible = false
	start_revive_timer()
	Global.check_for_game_over()

func start_revive_timer():
	is_downed = true
	revive_time_left = MAX_REVIVE_TIME
	revive_active = true
	revive_timer_label.visible = true
	revive_timer_label.text = "Revive in: " + str(int(revive_time_left))

func die_for_real():
	Global.player2_permadead = true 
	is_permadead = true
	revive_active = false
	is_downed = false
	revive_time_left = 0
	revive_timer_label.visible = false
	revive_timer_label.modulate = Color(1, 1, 1)

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

	Global.check_for_game_over()

func revive():
	is_dead = false
	is_downed = false
	is_permadead = false
	revive_active = false
	revive_progress = 0
	progress_bar.visible = false
	revive_label.visible = false
	revive_timer_label.visible = false
	p2_health = p2_maxHealth

	is_invincible = true
	animationplayer.play("reviveNeed_p2")

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

	Global.player2_health = p2_health
	Global.player2_revives = p2_revive

func take_damage(amount: int):
	if not is_dead and not is_invincible:
		p2_health -= amount
		p2_health = max(p2_health, 0)  # Clamp health to not go below 0
		Global.player2_health = p2_health

		spawn_damage_number(amount)
		flash_red()


func spawn_damage_number(amount: int):
	var dmg_label = preload("res://Players/Player scenes/FloatingText.tscn").instantiate()
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
	$Sprite_p2.modulate = default_color

func _on_revive_zone_body_entered(body: Node2D) -> void:
	if is_dead:
		progress_bar.visible = true
		print("Reviving...")

func _on_revive_zone_body_exited(body: Node2D) -> void:
	revive_progress = 0
	progress_bar.value = 0
	progress_bar.visible = false
