extends Control

const SAVE_PATH := "user://leaderboard.json"
var player1_score := 0
var player2_score := 0
var two_player_mode := false

@onready var player1_label = $Player1ScoreLabel
@onready var player2_label = $Player2ScoreLabel
@onready var leaderboard_list = $VBoxContainer/ItemList
@onready var back_button = $BackButton  # Adjust path if yours differs

func _ready():
	get_tree().paused = true

	back_button.grab_focus()
	set_process_input(true)

	if not back_button.is_connected("pressed", Callable(self, "_on_back_button_pressed")):
		back_button.connect("pressed", Callable(self, "_on_back_button_pressed"))

	"""
	var dir = DirAccess.open("user://")
	if dir and dir.file_exists("leaderboard.json"):
		dir.remove("leaderboard.json")
	"""  # use this to reset the leaderboard manually

	update_score_display()
	save_new_score()
	update_leaderboard_display()

func update_score_display():
	player1_label.text = "Player 1 Score: %d" % Global.player1_score
	if two_player_mode:
		player2_label.text = "Player 2 Score: %d" % Global.player2_score
		player2_label.show()
	else:
		player2_label.hide()

func load_leaderboard() -> Array:
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			var data = JSON.parse_string(content)
			if typeof(data) == TYPE_ARRAY:
				return data
	return []

func save_new_score():
	var leaderboard = load_leaderboard()

	var total_score = player1_score
	if two_player_mode:
		total_score += player2_score

	leaderboard.append(total_score)
	leaderboard.sort()
	leaderboard.reverse()
	leaderboard = leaderboard.slice(0, 10)

	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(leaderboard))

func update_leaderboard_display():
	var leaderboard = load_leaderboard()
	leaderboard_list.clear()
	for i in range(leaderboard.size()):
		leaderboard_list.add_item("%d. %d pts" % [i + 1, leaderboard[i]])

func _on_back_button_pressed() -> void:
	get_tree().paused = false

	if Global.previous_scene_path != "":
		var previous = load(Global.previous_scene_path)
		if previous:
			var scene = previous.instantiate()
			get_tree().get_root().add_child(scene)
			queue_free()
		else:
			print("Could not load pr0evious scene at: ", Global.previous_scene_path)
	else:
		print("No previous scene path set in Global.")

func _unhandled_input(event):
	if event.is_action_pressed("p1_a") or event.is_action_pressed("p2_a"):
		back_button.emit_signal("pressed")
