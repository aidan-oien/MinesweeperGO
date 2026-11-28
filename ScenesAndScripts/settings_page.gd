extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%Theme_Settings.pressed.connect(themes_tab)
	%Audio_Settings.pressed.connect(audio_tab)
	%Profile_Settings.pressed.connect(profile_tab)
	%Back_Button.pressed.connect(back) # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.

func themes_tab () -> void: 
	get_tree().change_scene_to_file("res://ScenesAndScripts/themes.tscn")

func audio_tab () -> void: 
	get_tree().change_scene_to_file("res://ScenesAndScripts/audio.tscn")

func profile_tab () -> void: 
	get_tree().change_scene_to_file("res://ScenesAndScripts/profile.tscn")

func back () -> void: 
	get_tree().change_scene_to_file("res://ScenesAndScripts/map.tscn")
