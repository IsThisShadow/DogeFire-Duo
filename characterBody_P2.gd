extends CharacterBody2D

@onready var animationplayer: AnimationPlayer = $Sprite_p2/AnimationPlayer_p2
@onready var progress_bar: ProgressBar = $ReviveZone_p2/ReviveProgressBar_p2
@onready var revive_label: Label = $ReviveLabel_p2
@onready var revive_count_label: Label = $ReviveCountLabel_p2
@onready var death_announcement: Label = get_node("/root/Main/DeathAnnouncement")
@onready var revive_timer_label: Label = $ReviveCountdownLabel_p2
@onready var weapon_container = $WeaponContainer
@onready var shoot_point = $WeaponContainer/Marker2D

# Weapon scenes
var weapon1_scene = preload("res://Scenes/Weapon1.tscn")
var weapon2_scene = preload("res://Scenes/Weapon2.tscn")
var weapon3_scene = preload("res://Scenes/Weapon3.tscn")
var weapon4_scene = preload("res://Scenes/Weapon4.tscn")
var weapon5_scene = preload("res://Scenes/Weapon5.tscn")

var current_weapon_instance = null
var current_weapon_index = 0

# Movement and state
const max_speed: int = 250
const acceleration: int = 5
const friction: int = 3
const revive_time := 2.5

var p2_health = 100
var p2_maxHealth = 100
var is_dead = false
var p2_max_revive = 3
var p2_revive = 0
var revive_progress := 0.0
var is_invincible := false
var revive_time_limit := 10
var revive_timer := 0.0

func _physics_process(delta: float) -> void:
	if is_dead:
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

	# Clamp position to screen
	var screen_size = get_viewport_rect().size
	var margin := 10.0
	position.x = clamp(position.x, margin, screen_size.x - margin)
	position.y = clamp(position.y, margin, screen_size.y - margin)

	if p2_health <= 0 and not is_dead:
		die()
		$ReviveZone_p2.monitoring = true
		$ReviveZone_p2/ReviveCollision_p2.disabled = false
		$CollisionShape2D_p2.disabled = true

	# Weapon switching
	if Input.is_action_just_pressed("p2_b"):
		equip_weapon(1)
	elif Input.is_action_just_pressed("p2_l1"):
		equip_weapon(2)
	elif Input.is_action_just_pressed("p2_l2"):
		equip_weapon(3)
	elif Input.is_action_just_pressed("p2_r1"):
		equip_weapon(4)
	elif Input.is_action_just_pressed("p2_r2"):
		equip_weapon(5)

func equip_weapon(index):
	if current_weapon_index == index:
		return

	current_weapon_index = index

	if current_weapon_instance:
		current_weapon_instance.queue_free()

	var new_weapon_scene
	match index:
		1: new_weapon_scene = weapon1_scene
		2: new_weapon_scene = weapon2_scene
		3: new_weapon_scene = weapon3_scene
		4: new_weapon_scene = weapon4_scene
		5: new_weapon_scene = weapon5_scene

	current_weapon_instance = new_weapon_scene.instantiate()
	weapon_container.add_child(current_weapon_instance)
	current_weapon_instance.global_position = shoot_point.global_position

func die():
	if p2_revive >= p2_max_revive:
		is_dead = true
		$CollisionShape2D_p2.disabled = true
		animationplayer.play("PermaDeath")
		await animationplayer.animation_finished

		var fade = get_tree().create_tween()
		fade.tween_property($Sprite_p2, "modulate:a", 0.0, 1.0)
		await fade.finished

		set_process(false)
		set_physics_process(false)
		visible = false

		death_announcement.text = "Player 2 has Died!"
		death_announcement.visible = true
		await get_tree().create_timer(2.0).timeout
		death_announcement.visible = false
		return

	is_dead = true
	$ReviveZone_p2.monitoring = true
	$ReviveZone_p2/ReviveCollision_p2.disabled = false
	animationplayer.play("death_p2")
	await animationplayer.animation_finished
	animationplayer.stop()
	animationplayer.play("reviveNeed_p2")
	revive_label.visible = true

func revive():
	is_dead = false
	revive_progress = 0
	progress_bar.visible = false
	revive_label.visible = false
	$ReviveZone_p2.monitoring = false
	p2_health = p2_maxHealth
	$ReviveZone_p2/ReviveCollision_p2.disabled = true
	$CollisionShape2D_p2.disabled = false

	is_invincible = true
	var blink = get_tree().create_tween()
	blink.set_loops(4)
	blink.tween_property($Sprite_p2, "modulate", Color(0.6, 0.6, 1.8), 0.25)
	blink.tween_property($Sprite_p2, "modulate", Color(1, 1, 1), 0.25)
	await get_tree().create_timer(2.0).timeout
	is_invincible = false

	p2_revive += 1
	if p2_revive >= p2_max_revive:
		revive_count_label.text = "No revives left!"
	else:
		var revives_left = p2_max_revive - p2_revive
		revive_count_label.text = str(revives_left) + " Revives Left"

	revive_count_label.visible = true
	await get_tree().create_timer(2.0).timeout
	revive_count_label.visible = false

func take_damage(amount: int):
	if not is_invincible and not is_dead:
		p2_health -= amount
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
		var damage := 50
		body.take_damage(damage)

func _on_revive_zone_p_2_body_entered(body: Node2D) -> void:
	if is_dead and body.name == "CharacterBodyP1":
		progress_bar.visible = true
		print("Player 1 entered revive zone")

func _on_revive_zone_p_2_body_exited(body: Node2D) -> void:
	if is_dead and body.name == "CharacterBodyP1":
		revive_progress = 0
		progress_bar.value = 0
		progress_bar.visible = false
		print("Player 1 exited revive zone")
