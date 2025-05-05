extends EnemyBase

@export var speed := 60
@export var max_health := 20

var bullet_scene = preload("res://enemies/enemy scenes/Enemy_1_bullet.tscn")

func _ready():
	_current_health = max_health

	if $enemy_1_SupportShip:
		$enemy_1_SupportShip.visible = true
	if $DeathSprite:
		$DeathSprite.visible = false

func _physics_process(delta):
	position.x -= speed * delta

	if position.x < -50:
		apply_escape_penalty()
		queue_free()

func die(shooter_player := 1):
	if is_dead:
		return
	is_dead = true

	if $enemy_1_SupportShip:
		$enemy_1_SupportShip.visible = false
	if $DeathSprite:
		$DeathSprite.visible = true

	if $AnimationPlayer:
		$AnimationPlayer.play("death_enemy_1")

	
	if shooter_player == 1:
		Global.player1_score += 15
	elif shooter_player == 2:
		Global.player2_score += 15


	await $AnimationPlayer.animation_finished
	queue_free()

func _on_bullet_timer_timeout() -> void:
	var bullet = bullet_scene.instantiate()
	bullet.position = position
	get_tree().current_scene.add_child(bullet)

func spawn_damage_number(amount: int):
	var label = $DamageLabel
	label.text = "-" + str(amount)
	label.modulate = Color(1, 0, 0, 1)
	label.visible = true
	label.position = Vector2(0, -20)

	var tween = get_tree().create_tween()
	tween.tween_property(label, "position", Vector2(0, -40), 0.2)
	tween.parallel().tween_property(label, "modulate:a", 0, 0.2)
	await tween.finished

	label.visible = false
	label.modulate = Color(1, 1, 1, 1)
	label.position = Vector2(0, -20)

func apply_escape_penalty():
	var penalty_amount = 20

	if Global.is_single_player:
		Global.player1_score -= penalty_amount
	else:
		Global.player1_score -= penalty_amount
		Global.player2_score -= penalty_amount
