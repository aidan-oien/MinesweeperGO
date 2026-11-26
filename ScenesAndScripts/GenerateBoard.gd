extends GridContainer

@export var flag_button: TextureButton
@export var face_button: TextureButton
@export var settings_button: TextureButton
@export var mine_label: Label
@export var timer_label: Label
@export var board_container: Container
@onready var label: Label = $"../../../../Label"

static var flagmode : bool = false
static var is_screen_touched : bool = false
static var dragging : bool = false
static var game_complete : bool = false

var timer : Timer
var time : int = 0

var COLS : int = 16
var ROWS : int = 30
#var COLS : int = 10
#var ROWS : int = 10
var MINES : int = 99 # numbers above TOTAL will be clamped

var TOTAL : int = COLS * ROWS
var win : bool = false
var FLAGS : int = 0
var REVEALED : int = 0

var rng : RandomNumberGenerator
var board : Dictionary[ Vector2i, Cell ]

var predrag : int = 0

var VP_WIDTH : int = ProjectSettings.get_setting("display/window/size/viewport_width")
var VP_HEIGHT : int = ProjectSettings.get_setting("display/window/size/viewport_height")

func debug_info() -> void:
		label.text = "pos: "+str(board_container.position) + "\n" + \
		"size: "+str( board_container.size ) + "\n" + \
		"scale: "+str( board_container.scale ) + "\n" + \
		str( get_window().size.x - board_container.size.x ) + "\n" + \
		str( VP_HEIGHT ) + "\n" + \
		str( board_container.size.x )+ "\n" + \
		"these "+str((((VP_WIDTH/2.0)-(board_container.position.x)) /100)/board_container.scale.x)+ "\n" + \
		"two   "+str((((VP_HEIGHT/2.0)-(board_container.position.y)) /100)/board_container.scale.y)+ "\n" + \
		#str(margin_container.size.x/(1*100))+ "\n" + \
		str(board_container.size.x/(2*100))+ "\n" + \
		""

# jesus.
func clamp_pos() -> void:
	var boardScale = board_container.scale.x
	board_container.position.x = clamp( board_container.position.x, \
										-board_container.size.x * boardScale + board_container.size.x/2, \
										(VP_WIDTH - board_container.size.x * boardScale) + (board_container.size.x * boardScale - board_container.size.x/2 ) )
	board_container.position.y = clamp( board_container.position.y, \
										-board_container.size.y * boardScale + board_container.size.y/2, \
										(VP_HEIGHT - board_container.size.y * boardScale) + (board_container.size.y * boardScale - board_container.size.y/2 ) )
	#debug_info()

# even more jesus.
func zoom( factor : int, zoomIn : bool ):
	var scaleSensitivity : float = 1.0 / 100.0
	var zoomOption : int = 1
	if !zoomIn:
		zoomOption = -1
	board_container.position -= Vector2( ((((VP_WIDTH/2.0)-(board_container.position.x)) /100)) * factor, \
										 ((((VP_HEIGHT/2.0)-(board_container.position.y)) /100)) * factor ) * zoomOption
	board_container.scale += factor * board_container.scale * scaleSensitivity * zoomOption

func _input( event ):
	if event is InputEventScreenDrag:
		if !dragging and predrag > 8:
			lock_cells()
			if !game_complete:
				face_button.texture_normal = load( "res://Assets/face.png" )
				face_button.texture_pressed = load( "res://Assets/face.png" )
			dragging = true
		if !dragging:
			predrag += 1
		board_container.position += event.relative
		clamp_pos()
	
	if event is InputEventScreenTouch:
		is_screen_touched = !is_screen_touched
		if !is_screen_touched and !game_complete:
			unlock_cells()
			dragging = false
			predrag = 0
	
	if event is InputEventMagnifyGesture:
		print( event.factor )
		if board_container.scale.x < 3.0 and board_container.scale.x > 0.8:
			zoom( event.factor, true )
		clamp_pos()
		
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			if board_container.scale.x < 3.0:
				zoom( 1, true )
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if board_container.scale.x > 0.8:
				zoom( 1, false )
		clamp_pos()


func _ready() -> void:
	rng = RandomNumberGenerator.new()
	rng.seed = 12345 # location will be here later
	
	timer = Timer.new()
	timer.wait_time = 1
	timer.timeout.connect( second_elapsed )
	add_child(timer)
	
	MINES = clamp( MINES, 0, TOTAL )
	mine_label.text = "%03d" % (MINES - FLAGS)
	
	columns = COLS
	
	# create board
	for i in TOTAL:
		var x : int = i % COLS
		@warning_ignore("integer_division")
		var y : int = i / COLS
		var cell : Cell = _make_cell( x, y )
		board.get_or_add( Vector2i( x, y ), cell )
		add_child( cell )
	
	# plot mines
	var minesPlaced : int = 0
	while minesPlaced < MINES:
		var x = rng.randi_range( 0, COLS - 1 )
		var y = rng.randi_range( 0, ROWS - 1 )
		var cell : Cell = board.get( Vector2i( x, y ) )
		if cell.isMine:
			continue
		cell.isMine = true
		for j in 9:
			var num_x : int = j % 3 + x - 1
			@warning_ignore("integer_division")
			var num_y : int = j / 3 + y - 1
			if num_x >= COLS or num_x < 0 or num_y >= ROWS or num_y < 0:
				continue
			board.get( Vector2i( num_x, num_y ) ).number += 1
		minesPlaced += 1
	
	# reveal all
	#for i in COLS * ROWS:
		#var x : int = i % COLS
		#var y : int = i / COLS
		#var cell : Cell = board.get( Vector2i( x, y ) )
		##cell.reveal()
		#if !cell.isMine:
			#cell.reveal()


func _make_cell( x : int, y : int ) -> Cell:
	var cell : Cell = Cell.new( x, y )
	cell.cell_interacted.connect( cell_update.bind( cell ) )
	cell.mine_revealed.connect( reveal_mines.bind( cell ) )
	cell.cell_revealed.connect( reveal_update )
	cell.cell_flagged.connect( flag_update )
	cell.button_held.connect( cell_held )
	return cell

# this function runs whenever a cell is pressed or held
func cell_update( isHeld : bool, cell: Cell  ) -> void: 
	face_button.texture_normal = load( "res://Assets/face.png" )
	face_button.texture_pressed = load( "res://Assets/face.png" )
	
	if timer.is_stopped():
		timer.start()
	
	#print( str(cell.x) + " " + str(cell.y) + " isMine?=" + str(cell.isMine) + " Number=" + str(cell.number) + " isHeld?=" + str(isHeld) )
	if cell.number > 0 and cell.revealed:
		var surroundingFlags : int = 0
		for i in 9:
			var num_x : int = i % 3 + cell.x - 1
			@warning_ignore("integer_division")
			var num_y : int = i / 3 + cell.y - 1
			if num_x >= COLS or num_x < 0 or num_y >= ROWS or num_y < 0:
				continue
			if num_x == cell.x and num_y == cell.y:
				continue
			if board.get( Vector2i( num_x, num_y ) ).flagged:
				surroundingFlags += 1
		if surroundingFlags == cell.number:
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
		@warning_ignore("integer_division")
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


func reveal_update() -> void:
	REVEALED += 1
	check_win_state()


func flag_update( isFlagged : bool ) -> void:
	if isFlagged:
		FLAGS += 1
	else:
		FLAGS -= 1
	if MINES - FLAGS < 0:
		mine_label.add_theme_color_override("font_color","#00ff00")
	else:
		mine_label.add_theme_color_override("font_color","#ff0000")
	mine_label.text = "%03d" % (abs(MINES - FLAGS))

# checks to see if the winning conditions are satisfied
func check_win_state() -> void:
	if REVEALED == TOTAL - MINES:
		all_cells( func( cell : Cell ):
			if !cell.revealed and !cell.flagged:
				cell.flag()
		)
		game_complete = true
		lock_cells()
		timer.stop()
		face_button.texture_normal = load( "res://Assets/face_win.png" )
		face_button.texture_pressed = load( "res://Assets/face_win.png" )
		print("win!")
		# game_win.emit( time )

# reveal all the mines on the board, this is also the game over function
func reveal_mines( hitCell : Cell ) -> void:
	game_complete = true
	lock_cells()
	timer.stop()
	face_button.texture_normal = load( "res://Assets/face_dead.png" )
	face_button.texture_pressed = load( "res://Assets/face_dead.png" )
	print("loss...")
	all_cells( func( cell : Cell ):
		if cell.isMine and cell != hitCell:
			cell.reveal()
		if cell.flagged and !cell.isMine:
			cell.wrong_flag()
	)
	# game_loss.emit( time )

# locks cells so they can't be pressed, activated when game is over or when dragging or pinching
func lock_cells() -> void:
	all_cells( func( cell : Cell ):
		cell.disabled = true
		cell.timer.stop()
	)

# unlock cells so player can interact with them again
func unlock_cells() -> void:
	all_cells( func( cell : Cell ):
		cell.disabled = false
	)

# sets the mode to flag mode, press and hold inputs are swapped
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
	
	all_cells( func( cell : Cell ):
		cell.update()
	)

# resets the game board
func _on_face_button_pressed() -> void:
	all_cells(func( cell : Cell ):
		if cell.flagged:
			cell.flag()
		cell.reset()
	)
	REVEALED = 0
	Cell.firstMine = true
	game_complete = false
	if flagmode:
		_on_flag_button_pressed()
	unlock_cells()
	timer.stop()
	timer.wait_time = 1
	time = 0
	timer_label.text = "%03d" % time
	face_button.texture_normal = load( "res://Assets/face.png" )
	face_button.texture_pressed = load( "res://Assets/face.png" )

# settings button functionality
func _on_settings_button_pressed() -> void:
	pass # Replace with function body.

func cell_held() -> void:
	face_button.texture_normal = load( "res://Assets/face_click.png" )
	face_button.texture_pressed = load( "res://Assets/face_click.png" )

# pass in a function you'd like to have happen to every cell on the board
func all_cells( function : Callable ) -> void:
	for i in TOTAL:
		var x : int = i % COLS
		@warning_ignore("integer_division")
		var y : int = i / COLS
		var cell : Cell = board.get( Vector2i( x, y ) )
		function.call( cell )

func second_elapsed():
	time += 1
	time = clamp( time, 0, 999 )
	timer_label.text = "%03d" % time
