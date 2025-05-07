extends Control

const SAVE_PATH_1P := "user://leaderboard_1p.json"
const SAVE_PATH_2P := "user://leaderboard_2p.json"

var player1_score := 0
var player2_score := 0

@onready var player1_label = $Player1ScoreLabel
@onready var player2_label = $Player2ScoreLabel
@onready var leaderboard_list_1p = $VBoxContainer/ItemList
@onready var leaderboard_list_2p = $VBoxContainer/ItemList2P
@onready var back_button = $BackButton
@onready var leaderboard_title = $VBoxContainer/LeaderboardTitle

func _ready():
	get_tree().paused = true

	back_button.grab_focus()
	set_process_input(true)

	if not back_button.is_connected("pressed", Callable(self, "_on_back_button_pressed")):
		back_button.connect("pressed", Callable(self, "_on_back_button_pressed"))

	update_score_display()
	leaderboard_title.text = "Leaderboard - 2 Player" if Global.is_two_player_mode else "Leaderboard - 1 Player"
	save_new_score()
	update_leaderboard_display()

func update_score_display():
	player1_label.text = "Player 1 Score: %d" % Global.player1_score
	if Global.is_two_player_mode:
		player2_label.text = "Player 2 Score: %d" % Global.player2_score
		player2_label.show()
	else:
		player2_label.hide()

func load_leaderboard(path: String) -> Array:
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			var data = JSON.parse_string(content)
			if typeof(data) == TYPE_ARRAY:
				return data
	return []

func save_new_score():
	var path = SAVE_PATH_2P if Global.is_two_player_mode else SAVE_PATH_1P
	var leaderboard = load_leaderboard(path)

	var total_score = Global.player1_score
	if Global.is_two_player_mode:
		total_score += Global.player2_score

	leaderboard.append(total_score)
	leaderboard.sort()
	leaderboard.reverse()
	leaderboard = leaderboard.slice(0, 10)

	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(leaderboard))

func update_leaderboard_display():
	leaderboard_list_1p.hide()
	leaderboard_list_2p.hide()

	var path = SAVE_PATH_2P if Global.is_two_player_mode else SAVE_PATH_1P
	var list_to_use = leaderboard_list_2p if Global.is_two_player_mode else leaderboard_list_1p

	var leaderboard = load_leaderboard(path)

	list_to_use.clear()
	for i in range(leaderboard.size()):
		list_to_use.add_item("%d. %d pts" % [i + 1, leaderboard[i]])

	list_to_use.show()

func _on_back_button_pressed() -> void:
	get_tree().paused = false

	if Global.previous_scene_path != "":
		var previous = load(Global.previous_scene_path)
		if previous:
			var scene = previous.instantiate()
			get_tree().get_root().add_child(scene)
			queue_free()
		else:
			print("Could not load previous scene at: ", Global.previous_scene_path)
	else:
		print("No previous scene path set in Global.")

func _unhandled_input(event):
	if event.is_action_pressed("p1_a") or event.is_action_pressed("p2_a"):
		back_button.emit_signal("pressed")
