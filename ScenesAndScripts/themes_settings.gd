extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%Classic.pressed.connect(classic_theme)
	%Light.pressed.connect(light_theme)
	%Dark.pressed.connect(dark_theme)
	%OLED_Black.pressed.connect(oled_black_theme)
	%Back_Button.pressed.connect(back) # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.

func classic_theme () -> void: 
	PlayerData.theme = "Classic"
	PlayerData.save_setts()
	PlayerData.theme_pick()

func light_theme () -> void: 
	PlayerData.theme = "Light"
	PlayerData.save_setts()
	PlayerData.theme_pick()

func dark_theme () -> void: 
	PlayerData.theme = "Dark"
	PlayerData.save_setts()
	PlayerData.theme_pick()

func oled_black_theme () -> void: 
	PlayerData.theme = "OLED_Black"
	PlayerData.save_setts()
	PlayerData.theme_pick()

func back () -> void: 
	get_tree().change_scene_to_file("res://ScenesAndScripts/settings.tscn")
