extends Node2D

# Declare variables for different weapon scripts (Weapon1.gd and Weapon2.gd will be handled as objects, not scripts)
var weapon1_scene = preload("res://Scenes/Weapon1.tscn")
var weapon2_scene = preload("res://Scenes/Weapon2.tscn")

@onready var player = $CharacterBody2D  # Referring to the node the script is attached to (TestPlayer)
@onready var weapon_container = $WeaponContainer  # A container node where weapons are added

var current_weapon = 1  # Start with weapon 1
var current_weapon_instance = null  # Instance of the current weapon

# Switch weapon method
func switch_weapon():
	if current_weapon == 1:
		# Switch to weapon 2
		change_weapon(weapon2_scene)
		current_weapon = 2
		print("Switched to Weapon 2")
	else:
		# Switch to weapon 1
		change_weapon(weapon1_scene)
		current_weapon = 1
		print("Switched to Weapon 1")

# Method to change the weapon
func change_weapon(new_weapon_scene):
	# Remove the current weapon if one exists
	if current_weapon_instance:
		current_weapon_instance.queue_free()
	
	# Instance the new weapon and add it to the container
	current_weapon_instance = new_weapon_scene.instantiate()
	weapon_container.add_child(current_weapon_instance)

# Input handling to switch weapons
func _process(delta):
	if Input.is_action_just_pressed("switch_weapon"):  # Assign a key for switching weapons (e.g., 'Q')
		print("Weapon switch button pressed")
		switch_weapon()
