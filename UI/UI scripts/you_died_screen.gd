extends Control

var joystick_cooldown := 0.2
var joystick_timer := 0.0
var p1_up_ready := true
var p1_down_ready := true
var p2_up_ready := true
var p2_down_ready := true

func _ready():
	get_tree().paused = true
	set_process(true)
	set_process_unhandled_input(true)

	await get_tree().process_frame  # Let any held input be released

	$VBoxContainer/PlayAgain.grab_focus()

func _process(delta):
	joystick_timer -= delta

	if Input.is_action_pressed("p1_up") and p1_up_ready and joystick_timer <= 0.0:
		move_focus_up()
		joystick_timer = joystick_cooldown
		p1_up_ready = false
	elif not Input.is_action_pressed("p1_up"):
		p1_up_ready = true

	if Input.is_action_pressed("p1_down") and p1_down_ready and joystick_timer <= 0.0:
		move_focus_down()
		joystick_timer = joystick_cooldown
		p1_down_ready = false
	elif not Input.is_action_pressed("p1_down"):
		p1_down_ready = true

	if Input.is_action_pressed("p2_up") and p2_up_ready and joystick_timer <= 0.0:
		move_focus_up()
		joystick_timer = joystick_cooldown
		p2_up_ready = false
	elif not Input.is_action_pressed("p2_up"):
		p2_up_ready = true

	if Input.is_action_pressed("p2_down") and p2_down_ready and joystick_timer <= 0.0:
		move_focus_down()
		joystick_timer = joystick_cooldown
		p2_down_ready = false
	elif not Input.is_action_pressed("p2_down"):
		p2_down_ready = true

func _unhandled_input(event):
	if event.is_action_pressed("p1_a") or event.is_action_pressed("p2_a"):
		var focused = get_viewport().gui_get_focus_owner()
		if focused and focused is Button:
			focused.emit_signal("pressed")

func move_focus_up():
	var focused = get_viewport().gui_get_focus_owner()
	var neighbor_path = focused.get_focus_neighbor(SIDE_TOP)
	if neighbor_path:
		var neighbor = focused.get_node(neighbor_path)
		neighbor.grab_focus()

func move_focus_down():
	var focused = get_viewport().gui_get_focus_owner()
	var neighbor_path = focused.get_focus_neighbor(SIDE_BOTTOM)
	if neighbor_path:
		var neighbor = focused.get_node(neighbor_path)
		neighbor.grab_focus()

func _on_play_again_pressed() -> void:
	print("Play Again pressed")
	get_tree().paused = false
	Global.reset_stats()
	Global.pause_menu = null
	get_tree().change_scene_to_file("res://UI/UI scenes/MainMenu.tscn")

func go_to_main_menu():
	get_tree().change_scene_to_file("res://UI/UI scenes/MainMenu.tscn")

func _on_see_your_score_pressed() -> void:
	Global.previous_scene_path = "res://UI/UI scenes/YouDiedScreen.tscn"

	var packed_scene = load("res://UI/UI scenes/ScoreScene.tscn")
	if packed_scene:
		var score_scene = packed_scene.instantiate()
		score_scene.player1_score = Global.player1_score
		score_scene.player2_score = Global.player2_score
		score_scene.two_player_mode = Global.is_two_player_mode
		get_tree().get_root().add_child(score_scene)
		queue_free()

func _on_quit_game_pressed() -> void:
	get_tree().quit()
