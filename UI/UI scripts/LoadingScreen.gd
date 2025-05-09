extends Control

@onready var animation_player: AnimationPlayer = $LoadingAnimation
@onready var music_player: AudioStreamPlayer = $LoadingMusicPlayer

func _ready():
	animation_player.play("load")
	animation_player.animation_finished.connect(_on_animation_finished)

	# Muffled audio setup
	_setup_muffled_audio()

func _setup_muffled_audio():
	# Create muffled bus if it doesn't exist
	if AudioServer.get_bus_index("Muffled") == -1:
		var new_bus_index = AudioServer.bus_count
		AudioServer.add_bus()
		AudioServer.set_bus_name(new_bus_index, "Muffled")
		var lowpass = AudioEffectLowPassFilter.new()
		lowpass.cutoff_hz = 1000
		AudioServer.add_bus_effect(new_bus_index, lowpass, 0)

	# Assign the music player to that bus and play
	music_player.bus = "Muffled"
	music_player.play()

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "load" and Global.next_scene_after_loading != "":
		get_tree().change_scene_to_file(Global.next_scene_after_loading)
