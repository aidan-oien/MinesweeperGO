extends Node

#@export var image: Texture2D
var volume := 67.0
var theme_sounds := false
var sound_override := "None"
var theme := "Classic"
var theme_color := Color(1, 1, 1)
var text_color := Color.BLACK

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#save_image(image)
	load_setts()
	save_setts() #if youre reading this AIDAN let a man name his functions in a FUN(C)ky way.
	actual_volume()
	theme_pick()
	get_tree().node_added.connect(themes)

func save_image(texture: Texture2D) -> void:
	var pfp := texture.get_image()
	pfp.save_png("user://pfp.png")

func save_setts() -> void:
	var config_file := ConfigFile.new()
	config_file.set_value("settings", "volume", volume)
	config_file.set_value("settings", "theme_sounds", theme_sounds)
	config_file.set_value("settings", "sound_override", sound_override)
	config_file.set_value("settings", "theme", theme)
	config_file.save("user://settings.cfg")

func load_setts() -> void:
	var config_file := ConfigFile.new()
	config_file.load("user://settings.cfg")
	volume = config_file.get_value("settings", "volume", volume)
	theme_sounds = config_file.get_value("settings", "theme_sounds", theme_sounds)
	sound_override = config_file.get_value("settings", "sound_override", sound_override)
	theme = config_file.get_value("settings", "theme", theme)

func actual_volume() -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(volume/100))#so that it actually goes down and doesnt blow your ear drums

func theme_pick() -> void:
	if theme == "Classic":
		theme_color=Color(1, 1, 1)
		text_color = Color.BLACK
	elif theme == "Light":
		theme_color=Color(1.5, 1.5, 1.5)
		text_color = Color.BLACK
	if theme == "Dark":
		theme_color=Color(0.5, 0.5, 0.5)
		text_color = Color.WHITE
	elif theme == "OLED_Black":
		theme_color=Color(0.1, 0.1, 0.1)
		text_color = Color.WHITE
#i cannot hard code all of that i will always find the lazy way
	for node in get_tree().root.find_children("*", "", true, false):
		themes(node)

func themes(node: Node) -> void:
	if node.is_in_group("no_theme"):
		return
	if node is NinePatchRect or node is ColorRect:
		node.self_modulate = theme_color
	if node is Label and node.get_theme_color("font color") != Color.RED: #so it skips over the level
		node.add_theme_color_override("font_color", text_color)
