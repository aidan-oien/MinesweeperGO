extends GridContainer

const COLS := 16
const ROWS := 30

const COLOR_FACE := Color("c0c0c0")
const COLOR_LIGHT := Color("ffffff")
const COLOR_SHADOW := Color("808080")

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

var board : Dictionary[ Vector2i, Cell ]

func _ready() -> void:
	columns = COLS
	for i in COLS * ROWS:
		var cell : Cell = _make_cell( i % COLS , i / COLS )
		board.get_or_add( Vector2i(), cell )
		add_child( cell )

func _make_cell( x : int, y : int ) -> Cell:
	var b : Cell = Cell.new( x, y )
	b.cell_pressed.connect( update.bind( b, 0 ) )
	b.cell_held.connect( update.bind( b, 1 ) )
	return b

func update( cell: Cell, isHeld : bool ):
	print( str(cell.x) + " " + str(cell.y) + " " + str(isHeld) )
