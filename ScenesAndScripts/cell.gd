class_name Cell
extends TextureButton

var x : int = -1
var y : int = -1
var number : int = 2
var isMine : bool = false
var revealed : bool = false
var flagged : bool = false

signal location

func _init( xPos : int, yPos : int ):
	x = xPos
	y = yPos
	set_texture( "res://Assets/cell.png", "res://Assets/cell_pressed.png" )
	self.pressed.connect( _on_pressed )

func reveal():
	pass

func _on_pressed() -> void:
	location.emit()

func set_texture( normalTexture : String, pressedTexture : String ):
	var normal : CompressedTexture2D = load( normalTexture )
	var pressed : CompressedTexture2D = load( pressedTexture )
	self.texture_normal = normal
	self.texture_pressed = pressed
