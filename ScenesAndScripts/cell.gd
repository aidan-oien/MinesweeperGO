class_name Cell
extends TextureButton

const NUM_COLORS : Dictionary = {
	0: Color("ffffff"),
	1: Color("0000ff"),
	2: Color("008000"),
	3: Color("ff0000"),
	4: Color("000080"),
	5: Color("800000"),
	6: Color("008080"),
	7: Color("000000"),
	8: Color("808080"),
}

static var flagmode : bool = false
static var dragged : bool = false
static var held : bool = false
static var firstMine : bool = true

#var timer : Timer

var timer : Timer
var label : Label

var x : int = -1
var y : int = -1
var number : int = 0
var isMine : bool = false
var revealed : bool = false
var flagged : bool = false

signal cell_pressed
signal cell_held
signal mine_revealed

func _init( xPos : int, yPos : int ):
	x = xPos
	y = yPos
	
	set_texture( "res://Assets/cell.png", "res://Assets/cell_pressed.png" )
	
	self.pressed.connect( _on_pressed )
	self.button_down.connect( _on_button_down )
	self.mouse_exited.connect( _on_mouse_exited )
	
	timer = Timer.new()
	timer.timeout.connect(_on_held)
	add_child(timer)
	
	label = Label.new()
	label.theme = load("res://minesweeperGO_theme.tres")
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size = Vector2( 20.0, 20.0 )
	label.position = Vector2( 0.5, -1.0 )
	label.add_theme_font_size_override("font_size", 16)
	add_child(label)

func set_flagmode( newFlagmode : bool ):
	flagmode = newFlagmode

func update():
	if !revealed and !flagged:
		if !flagmode:
			set_texture( "res://Assets/cell.png", "res://Assets/cell_pressed.png" )
		else:
			set_texture( "res://Assets/cell_flagmode.png", "res://Assets/cell_flagmode_pressed.png" )

func reveal():
	if flagged:
		return
	if !revealed:
		revealed = true
		set_texture( "res://Assets/cell_revealed.png", "res://Assets/cell_revealed.png" )
		if number != 0 and !isMine:
			label.add_theme_color_override("font_color", NUM_COLORS.get(number) )
			label.text = str(number)
	if isMine: 
		if firstMine:
			set_texture( "res://Assets/cell_mine_hit.png", "res://Assets/cell_mine_hit.png" )
			firstMine = false
			mine_revealed.emit()
		else:
			if !flagged:
				set_texture( "res://Assets/cell_mine.png", "res://Assets/cell_mine.png" )
	
func flag():
	if !revealed:
		if !flagged:
			set_texture( "res://Assets/cell_flag.png", "res://Assets/cell_flag_pressed.png" )
		else:
			if !flagmode:
				set_texture( "res://Assets/cell.png", "res://Assets/cell_pressed.png" )
			else:
				set_texture( "res://Assets/cell_flagmode.png", "res://Assets/cell_flagmode_pressed.png" )
		flagged = !flagged

func _on_button_down() -> void:
	timer.wait_time = 0.4
	timer.start()
	label.position = Vector2( 1.5, 0.0 )

func _on_held() -> void:
	timer.stop()
	held = true
	cell_held.emit()

func _on_mouse_exited() -> void:
	label.position = Vector2( 0.5, -1.0 )
	timer.stop()

func _on_pressed() -> void:
	label.position = Vector2( 0.5, -1.0 )
	if !dragged:
		if !held:
			timer.stop()
			cell_pressed.emit()
		else:
			held = false
	else:
		dragged = false

func set_texture( normalTexture : String, pressedTexture : String ):
	var normal : CompressedTexture2D = load( normalTexture )
	var press : CompressedTexture2D = load( pressedTexture )
	self.texture_normal = normal
	self.texture_pressed = press

#static func dragging():
	#timer.stop()
	#held = false
	#dragged = true
