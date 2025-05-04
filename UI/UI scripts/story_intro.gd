extends Control

@onready var story_label = $MarginContainer/VBoxContainer/StoryLabel
@onready var music := $MusicPlayer

var is_two_player_mode := Global.is_two_player_mode
var current_index := 0
var full_story := ""

@export var fade_out_time := 2.0  # seconds
var fade_out_timer := 0.0
var is_fading_out := false

func _ready():
	full_story = build_story_text(is_two_player_mode)
	story_label.text = ""
	type_story()

func build_story_text(is_two_player: bool) -> String:
	if is_two_player:
		return """Year 3147.
The Earth Federation is losing ground in Sector 9.

During a covert infiltration mission, two elite fighter pilots were ambushed, captured, and presumed lost behind enemy lines.

But they survived.

Stranded deep in hostile space, you’ve stolen back prototype starfighters from the enemy’s hangar.

Now, together, you must break through five heavily fortified quadrants and escape back to Federation space.

The odds are overwhelming. But you’re not alone.

Survive.
Fight back.
Get home.
"""
	else:
		return """Year 3147.
The Earth Federation is losing ground in Sector 9.

During a covert infiltration mission, an elite fighter pilot was ambushed, captured, and presumed lost behind enemy lines.

But he survived.

Stranded deep in hostile space, you’ve stolen back a prototype starfighter from the enemy’s hangar.

Now, you must break through five heavily fortified quadrants and escape back to Federation space.

The odds are against you.

Survive.
Fight back.
Get home.
"""

func type_story():
	if current_index < full_story.length():
		story_label.text += full_story[current_index]
		current_index += 1
		await get_tree().create_timer(0.01).timeout
		type_story()
	else:
		start_fade_out()
		await get_tree().create_timer(fade_out_time).timeout
		load_main_level()

func start_fade_out():
	is_fading_out = true
	fade_out_timer = fade_out_time
	set_process(true)

func _process(delta):
	if is_fading_out:
		fade_out_timer -= delta
		var t = clamp(fade_out_timer / fade_out_time, 0, 1)
		music.volume_db = lerp(-30, 0, t)  # fade out from 0 to -80 dB
		if fade_out_timer <= 0:
			music.stop()
			is_fading_out = false
			set_process(false)

func load_main_level():
	var next_scene = preload("res://Levels/mainLvl_1.tscn").instantiate()
	next_scene.set_2_players(is_two_player_mode)
	get_tree().get_root().add_child(next_scene)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = next_scene
