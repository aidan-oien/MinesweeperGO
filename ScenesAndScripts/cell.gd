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

const TEXT_POS_X : float = 0.5
const TEXT_POS_Y : float = 0.0
const TEXT_POS_PRESSED_X : float = 1.5
const TEXT_POS_PRESSED_Y : float = 1.0

static var flagmode : bool = false
static var isHeld : bool = false
static var firstMine : bool = true

var timer : Timer
var label : Label

var x : int = -1
var y : int = -1
var number : int = 0
var isMine : bool = false

var revealed : bool = false
var flagged : bool = false

signal cell_interacted( isHeld : bool )
signal mine_revealed
signal cell_revealed
signal cell_flagged( isFlagged : bool )
signal button_held

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
	label.theme = load( "res://minesweeperGO_theme.tres" )
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size = Vector2( 20.0, 20.0 )
	label.position = Vector2( TEXT_POS_X, TEXT_POS_Y )
	label.add_theme_font_size_override( "font_size", 18 )
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
	if isMine: 
		revealed = true
		if firstMine:
			set_texture( "res://Assets/cell_mine_hit.png", "res://Assets/cell_mine_hit.png" )
			firstMine = false
			mine_revealed.emit()
		else:
			if !flagged:
				set_texture( "res://Assets/cell_mine.png", "res://Assets/cell_mine.png" )
	if !revealed:
		revealed = true
		set_texture( "res://Assets/cell_revealed.png", "res://Assets/cell_revealed.png" )
		if number != 0 and !isMine:
			label.add_theme_color_override( "font_color", NUM_COLORS.get(number) )
			label.text = str(number)
		cell_revealed.emit()

func flag():
	if !revealed:
		flagged = !flagged
		if flagged:
			cell_flagged.emit( true )
			set_texture( "res://Assets/cell_flag.png", "res://Assets/cell_flag_pressed.png" )
		else:
			cell_flagged.emit( false )
			if !flagmode:
				set_texture( "res://Assets/cell.png", "res://Assets/cell_pressed.png" )
			else:
				set_texture( "res://Assets/cell_flagmode.png", "res://Assets/cell_flagmode_pressed.png" )

func wrong_flag():
	set_texture( "res://Assets/cell_wrong_flag.png", "res://Assets/cell_wrong_flag.png" )

func _on_button_down() -> void:
	button_held.emit()
	timer.wait_time = 0.4
	timer.start()
	label.position = Vector2( TEXT_POS_PRESSED_X, TEXT_POS_PRESSED_Y )

func _on_held() -> void:
	timer.stop()
	isHeld = true
	cell_interacted.emit( isHeld )

func _on_mouse_exited() -> void:
	label.position = Vector2( TEXT_POS_X, TEXT_POS_Y )
	timer.stop()

func _on_pressed() -> void:
	label.position = Vector2( TEXT_POS_X, TEXT_POS_Y )
	if !isHeld:
		timer.stop()
		cell_interacted.emit( isHeld )
	else:
		isHeld = false

func reset() -> void:
	revealed = 0;
	flagged = 0;
	label.text = ""
	set_texture( "res://Assets/cell.png", "res://Assets/cell_pressed.png" )

func set_texture( normalTexture : String, pressedTexture : String ):
	self.texture_normal = load( normalTexture )
	self.texture_pressed = load( pressedTexture )
