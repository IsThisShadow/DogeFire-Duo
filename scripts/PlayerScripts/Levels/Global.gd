extends Node

# === Player 1 Stats ===
var player1_health := 100
var player1_max_health := 100
var player1_revives := 0
var player1_max_revives := 3

# === Player 2 Stats ===
var player2_health := 100
var player2_max_health := 100
var player2_revives := 0
var player2_max_revives := 3

# === Pause & Scene Info ===
var is_two_player_mode := false
var current_scene_name := ""
var pause_menu: Control = null

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
		var scene_path = "res://PauseMenu2P.tscn" if is_two_player_mode else "res://PauseMenu1P.tscn"
		pause_menu = load(scene_path).instantiate()
		get_tree().get_root().add_child(pause_menu)
		pause_menu.process_mode = Node.PROCESS_MODE_ALWAYS  # Ensure it works while paused

	pause_menu.visible = true

# === Resume the game ===
func resume_game():
	get_tree().paused = false
	if pause_menu:
		pause_menu.queue_free()  # Clean it up
		pause_menu = null

# === Reset Method ===
func reset_stats():
	# Player 1
	player1_health = player1_max_health
	player1_revives = 0

	# Player 2
	player2_health = player2_max_health
	player2_revives = 0
