class_name Cell
extends TextureButton

var timer : Timer

var x : int = -1
var y : int = -1
var number : int = 2
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

func reveal():
	if flagged:
		pass
	if isMine: 
		set_texture( "res://Assets/cell_mine_hit.png", "res://Assets/cell_mine_hit.png" )
	if !revealed:
		set_texture( "res://Assets/cell_revealed.png", "res://Assets/cell_revealed.png" )
	
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
