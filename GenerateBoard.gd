extends GridContainer

const COLS := 16
const ROWS := 30
const CELL_SIZE := Vector2(67.5, 67.5)

const COLOR_HIDDEN := Color("2f3320")
const COLOR_HIDDEN_BORDER := Color("4a5028")
const COLOR_REVEALED := Color("8a6a30")
const NUM_COLORS := {
	1: Color("a8c8e8"),
	2: Color("9fd4a8"),
	3: Color("e8a8a8"),
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	columns = COLS
	for i in COLS * ROWS:
		add_child(_make_cell());
	_demo_reveal()

func _make_cell() -> Button:
	var b := Button.new()
	b.custom_minimum_size = Vector2(40, 67.5)   # width is only a minimum now
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_stylebox_override("normal", _box(COLOR_HIDDEN, COLOR_HIDDEN_BORDER))
	b.add_theme_stylebox_override("hover", _box(COLOR_HIDDEN.lightened(0.1), COLOR_HIDDEN_BORDER))
	b.add_theme_stylebox_override("pressed", _box(COLOR_REVEALED, COLOR_REVEALED.darkened(0.3)))
	b.add_theme_font_size_override("font_size", 44)
	return b

func _box(fill: Color, border: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = fill
	s.border_color = border
	s.set_border_width_all(3)
	return s

# this method is just to reveal the board (UI testing)
func _demo_reveal() -> void:
	var patch := [
		[1, 1, 1],
		[2, 0, 1],
		[1, 0, 1],
		[2, 1, 1],
	]
	
	var start_col := 6
	var start_row := 9
	
	for r in patch.size():
		for c in patch[r].size():
			var cell: Button = get_child((start_row + r) * COLS + start_col + c)
			var n: int = patch[r][c]
			cell.add_theme_stylebox_override("normal", _box(COLOR_REVEALED, COLOR_REVEALED.darkened(0.25)))
			cell.add_theme_stylebox_override("hover", _box(COLOR_REVEALED, COLOR_REVEALED.darkened(0.25)))
			if n > 0:
				cell.text = str(n)
				cell.add_theme_color_override("font_color", NUM_COLORS[n])
				cell.add_theme_color_override("font_disabled_color", NUM_COLORS[n])
