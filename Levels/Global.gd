extends Node

var unlocked_weapons = [true, true, false, false, false] #weapons one and two unlocked by default. 

# === Player 1 Stats ===
var player1_health := 100
var player1_max_health := 100
var player1_revives := 0
var player1_max_revives := 3
var player1_permadead = false
var player1_hearts := 3
var player1_score := 0

# === Player 2 Stats ===
var player2_health := 100
var player2_max_health := 100
var player2_revives := 0
var player2_max_revives := 3
var player2_permadead = false
var player2_score := 0

# === Pause & Scene Info ===
var is_two_player_mode := false
var current_scene_name := ""
var pause_menu: Control = null

var is_single_player: bool:
	get:
		return not is_two_player_mode

func _ready():
	set_process_input(true)

func _input(event):
	if event.is_action_pressed("p1_x") or event.is_action_pressed("p2_x"):
		if current_scene_name.begins_with("mainLvl_") or current_scene_name == "weapon_unlock_screen":
			toggle_pause_menu()
			
			
			
func unlock_weapon(index: int):
	if index >= 0 and index < unlocked_weapons.size():
		unlocked_weapons[index] = true
		
		
func toggle_pause_menu():
	if pause_menu:
		resume_game()
	else:
		pause_game()

func pause_game():
	var scene_path = "res://UI/UI scenes/PauseMenu2P.tscn" if is_two_player_mode else "res://UI/UI scenes/PauseMenu1P.tscn"

	if pause_menu:
		pause_menu.queue_free()
		pause_menu = null

	pause_menu = load(scene_path).instantiate()
	get_tree().get_root().add_child(pause_menu)

	pause_menu.visible = true
	pause_menu.set_process_input(true)
	pause_menu.set_process_unhandled_input(true)
	pause_menu.process_mode = Node.PROCESS_MODE_ALWAYS

	hide_gameplay()

func resume_game():
	get_tree().paused = false
	if pause_menu:
		pause_menu.queue_free()
		pause_menu = null
	show_gameplay()

func hide_gameplay():
	for node in get_tree().get_nodes_in_group("gameplay"):
		node.visible = false

func show_gameplay():
	for node in get_tree().get_nodes_in_group("gameplay"):
		node.visible = true

func reset_stats():
	player1_health = player1_max_health
	player1_revives = 0
	player1_permadead = false
	player1_score = 0
	
	player2_health = player2_max_health
	player2_revives = 0
	player2_permadead = false
	player2_score = 0

func check_for_game_over():
	var p1_dead = player1_health <= 0
	var p2_dead = player2_health <= 0

	if Global.is_single_player and p1_dead:
		show_you_died_screen()
	elif p1_dead and p2_dead:
		show_you_died_screen()

func show_you_died_screen():
	await get_tree().create_timer(0.5).timeout
	var scene = load("res://UI/UI scenes/YouDiedScreen.tscn")
	if scene:
		var screen = scene.instantiate()
		screen.set_process_input(true)
		screen.set_process_unhandled_input(true)
		get_tree().get_root().add_child(screen)
		hide_gameplay()
	else:
		print("YouDiedScreen scene not found!")

var weapon_locked_label: Label = null

func show_locked_weapon_warning(weapon_id: int):
	if weapon_locked_label and is_instance_valid(weapon_locked_label):
		weapon_locked_label.text = "Weapon " + str(weapon_id) + " is not unlocked yet!"
		weapon_locked_label.modulate = Color(1, 0, 0)
		weapon_locked_label.visible = true

		await get_tree().create_timer(1.0).timeout

		if is_instance_valid(weapon_locked_label):
			weapon_locked_label.visible = false
