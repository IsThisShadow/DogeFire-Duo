extends Control

@onready var continue_button = $UIBox/ContinueButton
@onready var weapon_name_label = $UIBox/weaponNameLabel
@onready var weapon_icon = $UIBox/WeaponIcon
@onready var next_level_label = $UIBox/nextLevelLabel
@onready var equip_info_label = $UIBox/equipInfoLabel

var is_two_player_mode := false
var next_level_index := 0

func _ready():
	continue_button.pressed.connect(_on_continue_pressed)
	_show_weapon_info()

func _show_weapon_info():
	match next_level_index:
		2:
			# weapon_icon.texture = preload("res://weapons/weapon3.png")
			weapon_name_label.text = "Weapon 3 - Laser Cannon"
			next_level_label.text = "Next: Entering Level 2"
			equip_info_label.text = "Press '3' to equip this weapon in-game"
		3:
			# weapon_icon.texture = preload("res://weapons/weapon4.png")
			weapon_name_label.text = "Weapon 4 - Plasma Beam"
			next_level_label.text = "Next: Entering Level 3"
			equip_info_label.text = "Press '4' to equip this weapon in-game"
		4:
			# weapon_icon.texture = preload("res://weapons/weapon5.png")
			weapon_name_label.text = "Weapon 5 - Omega Blaster"
			next_level_label.text = "Next: Entering Level 4"
			equip_info_label.text = "Press '5' to equip this weapon in-game"
		5:
			# weapon_icon.texture = null
			weapon_name_label.text = "ALL Weapons Unlocked!"
			next_level_label.text = "Next: Entering Final Level"
			equip_info_label.text = "Use 1-5 keys to switch between all weapons"
		_:
			weapon_icon.texture = null
			weapon_name_label.text = "New Weapon Unlocked!"
			next_level_label.text = "Next Level Incoming..."
			equip_info_label.text = ""

func _on_continue_pressed():
	var next_scene_path = "res://scripts/PlayerScripts/Levels/mainLvl_%d.tscn" % next_level_index
	var next_scene = load(next_scene_path).instantiate()
	next_scene.set_2_players(is_two_player_mode)

	var current = get_tree().current_scene
	if current:
		current.queue_free()

	get_tree().get_root().add_child(next_scene)
	get_tree().current_scene = next_scene
