extends CharacterBody2D
"""
When the player starts the game it starts as the damaged version of the ship instead of the normal version.
pp
When firing weapon and switching to another and back to the same it ignores the cooldown.
"""
@onready var animationplayer: AnimationPlayer = $Sprite_p1/AnimationPlayer_p1
@onready var progress_bar: ProgressBar = $ReviveZone/ReviveProgressBar
@onready var revive_label: Label = $ReviveLabel
@onready var revive_count_label: Label = $ReviveCountLabel
@onready var weapon_container: Node2D = $WeaponContainer
@onready var revive_timer_label: Label = $ReviveTimerLabel
@onready var heart_ui := $HeartUI

var death_announcement: Label = null
var is_single_player := Global.is_single_player
var default_color := Color(1.2, 0.5, 0.5)  # red tint for P1

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

const max_speed := 250
const acceleration := 5
const friction := 3
const revive_time := 2.5
const MAX_REVIVE_TIME := 10.0

var revive_active := false
var is_downed := false
var revive_time_left := 10.0
var p1_health := 10
var p1_maxHealth = 100
var is_dead = false
var is_permadead = false
var p1_max_revive = 3
var p1_revive = 0
var revive_progress := 0.0
var is_invincible := false
var p1_hearts := 3


func get_weapon_name():
	return weapon_names.get(selected_weapon_id, "no wepaon selected")
	
	
	
func _ready():
	if Global.player1_permadead:
		queue_free()
		return

	$Sprite_p1.modulate = default_color
	death_announcement = get_tree().get_first_node_in_group("death_announcement")
	p1_health = Global.player1_health
	p1_revive = Global.player1_revives

	if is_single_player:
		p1_hearts = Global.player1_hearts
		$HeartUI.visible = true
		update_heart_display()
		$ReviveZone.visible = false
		revive_label.visible = false
		revive_count_label.visible = false
		revive_timer_label.visible = false
	else:
		$HeartUI.visible = false

func _physics_process(delta):
	if is_dead:
		if is_single_player:
			die_for_real()
			return

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

		if $ReviveZone.monitoring:
			var is_being_revived = false
			for body in $ReviveZone.get_overlapping_bodies():
				if body.name == "CharacterBodyP2":
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

	var screen_size = get_viewport_rect().size
	var margin := 10.0
	position.x = clamp(position.x, margin, screen_size.x - margin)
	position.y = clamp(position.y, margin, screen_size.y - margin)

	if p1_health <= 0 and not is_dead:
		die()

	if Input.is_action_just_pressed("p1_b"):
		select_weapon(1)
	elif Input.is_action_just_pressed("p1_l1"):
		select_weapon(2)
	elif Input.is_action_just_pressed("p1_l2"):
		select_weapon(3)
	elif Input.is_action_just_pressed("p1_r1"):
		select_weapon(4)
	elif Input.is_action_just_pressed("p1_r2"):
		select_weapon(5)

	if Input.is_action_just_pressed("p1_a") and current_weapon:
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
		current_weapon.player_id = 1  # <-- Player 1
		weapon_container.add_child(current_weapon)

func die():
	is_dead = true

	if is_single_player:
		p1_hearts -= 1
		Global.player1_hearts = p1_hearts
		update_heart_display()
		if p1_hearts <= 0:
			die_for_real()
		else:
			is_dead = false
			p1_health = p1_maxHealth
			Global.player1_health = p1_health
			$CollisionShape2D_p1.call_deferred("set_disabled", false)
			set_physics_process(true)
			set_process(true)
			visible = true
		return

	if p1_revive >= p1_max_revive:
		die_for_real()
		return

	$ReviveZone.call_deferred("set_monitoring", true)
	$ReviveZone/ReviveCollision.call_deferred("set_disabled", false)
	$CollisionShape2D_p1.call_deferred("set_disabled", true)

	animationplayer.play("Death_p1")
	await animationplayer.animation_finished
	animationplayer.stop()
	animationplayer.play("reviveNeed_p1")

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
	Global.player1_permadead = true
	is_permadead = true
	revive_active = false
	is_downed = false
	revive_time_left = 0
	revive_timer_label.visible = false
	revive_timer_label.modulate = Color(1, 1, 1)

	$CollisionShape2D_p1.call_deferred("set_disabled", true)
	animationplayer.play("PermaDeath")
	await animationplayer.animation_finished
	set_physics_process(false)
	set_process(false)
	visible = false

	if death_announcement:
		death_announcement.text = "Player 1 has Died!"
		death_announcement.visible = true
		await get_tree().create_timer(2.0).timeout
		death_announcement.visible = false

	Global.check_for_game_over()

func revive():
	if not is_dead or is_permadead:
		return

	is_dead = false
	is_downed = false
	is_permadead = false
	revive_active = false
	revive_progress = 0
	progress_bar.visible = false
	revive_label.visible = false
	revive_timer_label.visible = false

	p1_health = p1_maxHealth
	Global.player1_health = p1_health

	is_invincible = true
	animationplayer.play("reviveNeed_p1")

	while $ReviveZone.get_overlapping_bodies().size() > 0:
		await get_tree().process_frame

	$CollisionShape2D_p1.call_deferred("set_disabled", false)
	$ReviveZone.call_deferred("set_monitoring", false)
	$ReviveZone/ReviveCollision.call_deferred("set_disabled", true)

	await get_tree().create_timer(2.0).timeout
	is_invincible = false

	p1_revive += 1
	Global.player1_revives = p1_revive

	revive_count_label.text = "No revives left!" if p1_revive >= p1_max_revive else str(p1_max_revive - p1_revive) + " Revives Left"
	revive_count_label.visible = true
	await get_tree().create_timer(2.0).timeout
	revive_count_label.visible = false

func update_heart_display():
	if not is_single_player:
		return
	for i in range(3):
		var heart = heart_ui.get_child(i)
		heart.visible = i < p1_hearts

func take_damage(amount: int):
	if not is_dead and not is_invincible:
		p1_health -= amount
		Global.player1_health = p1_health
		spawn_damage_number(amount)
		flash_red()

		if p1_health <= 0:
			if is_single_player:
				p1_hearts -= 1
				Global.player1_hearts = p1_hearts
				update_heart_display()

				if p1_hearts <= 0:
					is_dead = true
				else:
					p1_health = p1_maxHealth
					Global.player1_health = p1_health
			else:
				die()

func spawn_damage_number(amount: int):
	var dmg_label = preload("res://FloatingText.tscn").instantiate()
	dmg_label.text = "-" + str(amount)
	dmg_label.position = Vector2(-25, -10)
	dmg_label.rotation_degrees = 270
	add_child(dmg_label)

func flash_red():
	var original_pos = position
	$Sprite_p1.modulate = Color(1, 0.3, 0.3)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", original_pos + Vector2(6, -4), 0.04)
	tween.tween_property(self, "position", original_pos - Vector2(-6, 4), 0.04)
	tween.tween_property(self, "position", original_pos, 0.03)
	await tween.finished
	$Sprite_p1.modulate = default_color

func _on_test_area_body_entered(_body: Node2D) -> void:
	pass

func _on_revive_zone_body_entered(_body: Node2D) -> void:
	if is_dead:
		progress_bar.visible = true
		print("Reviving...")

func _on_revive_zone_body_exited(_body: Node2D) -> void:
	revive_progress = 0
	progress_bar.value = 0
	progress_bar.visible = false
