extends Node

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

# === Game Mode Shortcut ===
var is_single_player: bool:
	get:
		return not is_two_player_mode

# === Called when game starts ===
func _ready():
	set_process_input(true)

# === Listen for pause trigger ===
func _input(event):
	if event.is_action_pressed("p1_x") or event.is_action_pressed("p2_x"):
		if current_scene_name.begins_with("mainLvl_") or current_scene_name == "weapon_unlock_screen":
			toggle_pause_menu()

# === Toggle pause on/off ===
func toggle_pause_menu():
	if get_tree().paused:
		resume_game()
	else:
		pause_game()

# === Pause the game ===
func pause_game():
	get_tree().paused = true

	if not pause_menu:
		var scene_path = "res://UI/UI scenes/PauseMenu2P.tscn" if is_two_player_mode else "res://UI/UI scenes/PauseMenu1P.tscn"
		pause_menu = load(scene_path).instantiate()
		get_tree().get_root().add_child(pause_menu)
		pause_menu.process_mode = Node.PROCESS_MODE_ALWAYS

	pause_menu.visible = true
	hide_gameplay()

# === Resume the game ===
func resume_game():
	get_tree().paused = false
	if pause_menu:
		pause_menu.queue_free()
		pause_menu = null
	show_gameplay()

# === Hide and Show Gameplay Nodes (HUD, players) ===
func hide_gameplay():
	for node in get_tree().get_nodes_in_group("gameplay"):
		node.visible = false

func show_gameplay():
	for node in get_tree().get_nodes_in_group("gameplay"):
		node.visible = true

# === Reset Stats ===
func reset_stats():
	player1_health = player1_max_health
	player1_revives = 0
	player1_permadead = false
	player1_score = 0 
	
	
	player2_health = player2_max_health
	player2_revives = 0
	player2_permadead = false
	player2_score = 0 
# === Check for total game over ===
func check_for_game_over():
	var p1_dead = player1_health <= 0
	var p2_dead = player2_health <= 0

	if Global.is_single_player and p1_dead:
		show_you_died_screen()
	elif p1_dead and p2_dead:
		show_you_died_screen()

func show_you_died_screen():
	await get_tree().create_timer(0.5).timeout  # Delay for polish
	var scene = load("res://UI/UI scenes/YouDiedScreen.tscn")
	if scene:
		var screen = scene.instantiate()

		screen.pause_mode = 1  # PAUSE_MODE_PROCESS
		screen.set_process_input(true)
		screen.set_process_unhandled_input(true)
		screen.set_process_focus(true)

		get_tree().get_root().add_child(screen)
		hide_gameplay()
		get_tree().paused = true
	else:
		print("YouDiedScreen scene not found!")
