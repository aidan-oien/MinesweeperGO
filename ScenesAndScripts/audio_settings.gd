extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%HSlider.value = PlayerData.volume
	%CheckButton.button_pressed = PlayerData.theme_sounds
	if PlayerData.sound_override == "None":
		%OptionButton.select(0)
	elif PlayerData.sound_override == "Classic":
		%OptionButton.select(1)
	%Back_Button.pressed.connect(back)
	
	%HSlider.value_changed.connect(volume_changed)
	%CheckButton.toggled.connect(sound_toggled)
	%OptionButton.item_selected.connect(override_sound_toggled)

func volume_changed(value: float) -> void:
	PlayerData.volume = value
	PlayerData.actual_volume()
	PlayerData.save_setts()

func sound_toggled(on: bool) -> void:
	PlayerData.theme_sounds = on
	PlayerData.save_setts()
func override_sound_toggled(index: int) -> void:
	PlayerData.sound_override = %OptionButton.get_item_text(index)
	PlayerData.save_setts()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func back () -> void: 
	get_tree().change_scene_to_file("res://ScenesAndScripts/settings.tscn")
