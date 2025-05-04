extends Control

const SAVE_PATH := "user://leaderboard.json"
var player1_score := 0
var player2_score := 0
var two_player_mode := false

@onready var player1_label = $VBoxContainer/Player1ScoreLabel
@onready var player2_label = $VBoxContainer/Player2ScoreLabel
@onready var leaderboard_list = $VBoxContainer/LeaderboardList

func _ready():
	update_score_display()
	load_leaderboard()
	update_leaderboard_display()
	save_new_score()

func update_score_display():
	player1_label.text = "Player 1 Score: %d" % player1_score
	if two_player_mode:
		player2_label.text = "Player 2 Score: %d" % player2_score
		player2_label.show()
	else:
		player2_label.hide()

func load_leaderboard() -> Array:
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		var data = JSON.parse_string(content)
		if typeof(data) == TYPE_ARRAY:
			return data
	return []

func save_new_score():
	var leaderboard = load_leaderboard()
	leaderboard.append(player1_score)
	if two_player_mode:
		leaderboard.append(player2_score)
	leaderboard.sort()
	leaderboard.reverse()
	leaderboard = leaderboard.slice(0, 10)  # Keep top 10

	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(leaderboard))

func update_leaderboard_display():
	var leaderboard = load_leaderboard()
	leaderboard_list.clear()
	for i in leaderboard.size():
		leaderboard_list.add_item("%d. %d pts" % [i + 1, leaderboard[i]])


func _on_back_button_pressed() -> void:
	pass # Replace with function body.
