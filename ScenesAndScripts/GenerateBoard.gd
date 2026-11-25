extends GridContainer

@onready var flag_button: TextureButton = $"../../../../../TopBar/MarginContainer/MarginContainer12/HBoxContainer/FlagButton"
@onready var face_button: TextureButton = $"../../../../../TopBar/MarginContainer/MarginContainer12/HBoxContainer/FaceButton"
@onready var settings_button: TextureButton = $"../../../../../TopBar/MarginContainer/MarginContainer12/HBoxContainer/SettingsButton"
@onready var board_container: Container = $"../../../.."

static var flagmode : bool = false
static var is_screen_touched : bool = false
static var dragging : bool = false
static var game_complete : bool = false

var COLS : int = 16
var ROWS : int = 30
var MINES : int = 99
var rng : RandomNumberGenerator
var board : Dictionary[ Vector2i, Cell ]

func _input( event ):
	if event is InputEventScreenDrag:
		if !dragging:
			lock_cells()
		dragging = true
		board_container.position += event.relative
	
	if event is InputEventScreenTouch:
		is_screen_touched = !is_screen_touched
		if !is_screen_touched and !game_complete:
			unlock_cells()
			dragging = false
	
	if event is InputEventMagnifyGesture:
		print(event.factor)
		board_container.scale += event.factor
		board_container.scale = clamp( board_container.scale, Vector2( 0.8, 0.8 ), Vector2( 2.0, 2.0 ) )
		
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			if board_container.scale.x < 3.0:
				board_container.scale += Vector2( 0.02, 0.02 )
				board_container.position -= Vector2( position.x, position.y )
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if board_container.scale.x > 0.8:
				board_container.scale -= Vector2( 0.02, 0.02 )
				board_container.position += Vector2( position.x, position.y )
		print(board_container.scale.x)


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
	cell.mine_revealed.connect( reveal_mines.bind( cell ) )
	return cell

# this function runs whenever a cell is pressed or held
func cell_update( cell: Cell, isHeld : bool ) -> void: 
	print( str(cell.x) + " " + str(cell.y) + " isMine?=" + str(cell.isMine) + " Number=" + str(cell.number) + " isHeld?=" + str(isHeld) )
	
	if cell.number > 0 and cell.revealed:
		var flags : int = 0
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
		if cell.number == 0:
			open_area( cell )
	else:
		cell.flag()


func open_area( cell : Cell ) -> void:
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


func reveal_mines( hitCell : Cell ) -> void:
	game_complete = true
	lock_cells()
	for i in COLS * ROWS:
		var x : int = i % COLS
		var y : int = i / COLS
		var cell : Cell = board.get( Vector2i( x, y ) )
		if cell.isMine and cell != hitCell:
			cell.reveal()


func lock_cells() -> void:
	for i in COLS * ROWS:
		var x : int = i % COLS
		var y : int = i / COLS
		var cell : Cell = board.get( Vector2i( x, y ) )
		cell.disabled = true
		cell.timer.stop()


func unlock_cells() -> void:
	for i in COLS * ROWS:
		var x : int = i % COLS
		var y : int = i / COLS
		var cell : Cell = board.get( Vector2i( x, y ) )
		cell.disabled = false


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
