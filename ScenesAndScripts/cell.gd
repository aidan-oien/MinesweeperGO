class_name Cell
extends TextureButton

const NUM_COLORS : Dictionary = {
	1: Color("0000ff"),
	2: Color("008000"),
	3: Color("ff0000"),
	4: Color("000080"),
	5: Color("800000"),
	6: Color("008080"),
	7: Color("000000"),
	8: Color("808080"),
}

var timer : Timer
var label : Label

var x : int = -1
var y : int = -1
var number : int = 0
var isMine : bool = false
var revealed : bool = false
var flagged : bool = false
var held : bool = false



signal cell_pressed
signal cell_held

func _init( xPos : int, yPos : int ):
	x = xPos
	y = yPos
	
	set_texture( "res://Assets/cell.png", "res://Assets/cell_pressed.png" )
	
	self.pressed.connect( _on_pressed )
	self.button_down.connect( _on_button_down )
	
	timer = Timer.new()
	timer.timeout.connect(_on_held)
	add_child(timer)
	
	label = Label.new()
	label.theme = load("res://minesweeperGO_theme.tres")
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size = Vector2( 20.0, 20.0 )
	label.position = Vector2( 0.0, 0.0 )
	label.add_theme_font_size_override("font_size", 15)
	add_child(label)

func reveal():
	if flagged:
		pass
		return
	if isMine: 
		set_texture( "res://Assets/cell_mine_hit.png", "res://Assets/cell_mine_hit.png" )
		return
	if !revealed:
		revealed = true
		set_texture( "res://Assets/cell_revealed.png", "res://Assets/cell_revealed.png" )
		if number != 0:
			label.add_theme_color_override("font_color", NUM_COLORS.get(number) )
			label.text = str(number)
	
func flag():
	if !flagged:
		set_texture( "res://Assets/cell_flag.png", "res://Assets/cell_flag_pressed.png" )
	else:
		set_texture( "res://Assets/cell.png", "res://Assets/cell_pressed.png" )
	flagged = !flagged

func _on_button_down() -> void:
	timer.wait_time = 0.5
	timer.start()

func _on_held():
	timer.stop()
	held = true
	cell_held.emit()

func _on_pressed() -> void:
	if !held:
		timer.stop()
		cell_pressed.emit()
	else:
		held = false

func set_texture( normalTexture : String, pressedTexture : String ):
	var normal : CompressedTexture2D = load( normalTexture )
	var press : CompressedTexture2D = load( pressedTexture )
	self.texture_normal = normal
	self.texture_pressed = press
