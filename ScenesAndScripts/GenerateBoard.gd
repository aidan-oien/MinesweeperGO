extends GridContainer

const NUM_COLORS := {
	1: Color("0000ff"),
	2: Color("008000"),
	3: Color("ff0000"),
	4: Color("000080"),
	5: Color("800000"),
	6: Color("008080"),
	7: Color("000000"),
	8: Color("808080"),
}

var COLS := 16
var ROWS := 30
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
	
	for i in COLS * ROWS:
		var x : int = i % COLS
		var y : int = i / COLS
		var cell : Cell = board.get( Vector2i( x, y ) )
		cell.reveal()

func _make_cell( x : int, y : int ) -> Cell:
	var cell : Cell = Cell.new( x, y )
	cell.cell_pressed.connect( update.bind( cell, 0 ) )
	cell.cell_held.connect( update.bind( cell, 1 ) )
	return cell

func update( cell: Cell, isHeld : bool ):
	print( str(cell.x) + " " + str(cell.y) + " isMine?=" + str(cell.isMine) + " Number=" + str(cell.number) )
	cell.reveal()
