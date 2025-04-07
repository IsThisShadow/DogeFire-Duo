extends Control

func _ready():
	$VBoxContainer/OnePlayerButton.text = "1 Player"
	$VBoxContainer/TwoPlayerButton.text = "2 Players"

	$VBoxContainer/OnePlayerButton.pressed.connect(_on_one_player)
	$VBoxContainer/TwoPlayerButton.pressed.connect(_on_two_player)

func _on_one_player():
	_load_ready_screen(false)

func _on_two_player():
	_load_ready_screen(true)

func _load_ready_screen(is_two_player: bool):
	var menu2_scene = preload("res://mainMenu_2.tscn").instantiate()
	menu2_scene.is_two_player_mode = is_two_player

	var current = get_tree().current_scene
	if current:
		current.queue_free()

	get_tree().get_root().add_child(menu2_scene)
	get_tree().current_scene = menu2_scene
