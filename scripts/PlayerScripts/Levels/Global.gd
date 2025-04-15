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

# === Reset Method (optional) ===
func reset_stats():
	# Player 1
	player1_health = player1_max_health
	player1_revives = 0
	
	# Player 2
	player2_health = player2_max_health
	player2_revives = 0
