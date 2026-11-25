extends GridContainer

@onready var flag_button: TextureButton = $"../../../../../TopBar/MarginContainer/MarginContainer12/HBoxContainer/FlagButton"
@onready var face_button: TextureButton = $"../../../../../TopBar/MarginContainer/MarginContainer12/HBoxContainer/FaceButton"
@onready var settings_button: TextureButton = $"../../../../../TopBar/MarginContainer/MarginContainer12/HBoxContainer/SettingsButton"

static var flagmode : bool = false

var COLS : int = 16
var ROWS : int = 30
var MINES : int = 99
var rng : RandomNumberGenerator
var board : Dictionary[ Vector2i, Cell ]

func _ready() -> void:
	rng = RandomNumberGenerator.new()
	rng.seed = 12345 # location will be here later
	
	# create board
	for i in COLS * ROWS:
		var x : int = i % COLS
		var y : int = i / COLS
		var cell : Cell = _make_cell( x, y )
		board.get_or_add( Vector2i( x, y ), cell )
		add_child( cell )
	
	# plot mines
	for i in MINES:
		var x = rng.randi_range( 0, COLS - 1 )
		var y = rng.randi_range( 0, ROWS - 1 )
		var cell : Cell = board.get( Vector2i( x, y ) )
		if cell.isMine:
			i -= 1
			continue
		cell.isMine = true
		for j in 9:
			var num_x : int = j % 3 + x - 1
			var num_y : int = j / 3 + y - 1
			if num_x >= COLS or num_x < 0 or num_y >= ROWS or num_y < 0:
				continue
			board.get( Vector2i( num_x, num_y ) ).number += 1
	
	# reveal all
	#for i in COLS * ROWS:
		#var x : int = i % COLS
		#var y : int = i / COLS
		#var cell : Cell = board.get( Vector2i( x, y ) )
		#cell.reveal()

func _make_cell( x : int, y : int ) -> Cell:
	var cell : Cell = Cell.new( x, y )
	cell.cell_pressed.connect( cell_update.bind( cell, 0 ) )
	cell.cell_held.connect( cell_update.bind( cell, 1 ) )
	return cell

func cell_update( cell: Cell, isHeld : bool ): 
	print( str(cell.x) + " " + str(cell.y) + " isMine?=" + str(cell.isMine) + " Number=" + str(cell.number) )
	
	if cell.number > 0 and cell.revealed:
		var flags : int
		for i in 9:
			var num_x : int = i % 3 + cell.x - 1
			var num_y : int = i / 3 + cell.y - 1
			if num_x >= COLS or num_x < 0 or num_y >= ROWS or num_y < 0:
				continue
			if num_x == cell.x and num_y == cell.y:
				continue
			if board.get( Vector2i( num_x, num_y ) ).flagged:
				flags += 1
		if flags == cell.number:
			open_area( cell )
	
	if flagmode:
		isHeld = !isHeld
	
	if !isHeld:
		cell.reveal()
		if cell.isMine:
			pass # end game
		if cell.number == 0:
			open_area( cell )
	else:
		cell.flag()

func open_area( cell : Cell ):
	for i in 9:
		var num_x : int = i % 3 + cell.x - 1
		var num_y : int = i / 3 + cell.y - 1
		if num_x >= COLS or num_x < 0 or num_y >= ROWS or num_y < 0:
			continue
		if num_x == cell.x and num_y == cell.y:
			continue
		var nextCell : Cell = board.get( Vector2i( num_x, num_y ) )
		if nextCell.revealed or nextCell.flagged:
			continue
		nextCell.reveal()
		if nextCell.number == 0:
			open_area( nextCell )

func _on_flag_button_pressed() -> void:
	flagmode = !flagmode
	var flagButtonTexture : CompressedTexture2D
	if !flagmode:
		flagButtonTexture = load( "res://Assets/flag.png" )
	else:
		flagButtonTexture = load( "res://Assets/flag_flagmode.png" )
	flag_button.texture_normal = flagButtonTexture
	flag_button.texture_pressed = flagButtonTexture
	
	Cell.flagmode = flagmode
	
	for i in COLS * ROWS:
		var x : int = i % COLS
		var y : int = i / COLS
		var cell : Cell = board.get( Vector2i( x, y ) )
		cell.update()
