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

var _hidden_style: StyleBoxTexture
var _hidden_pressed_style: StyleBoxFlat
var _revealed_style: StyleBoxFlat

func _ready() -> void:
	columns = COLS
	_build_styles()
	for i in COLS * ROWS:
		add_child(_make_cell())
	_demo_reveal()

func _build_styles() -> void:
	# Raised bevel: white top/left, gray bottom/right
	var img := Image.create(8, 8, false, Image.FORMAT_RGBA8)
	img.fill(COLOR_FACE)
	for i in 8:
		for t in 2:
			img.set_pixel(i, t, COLOR_LIGHT)          # top
			img.set_pixel(t, i, COLOR_LIGHT)          # left
	for i in 8:
		for t in 2:
			img.set_pixel(i, 7 - t, COLOR_SHADOW)     # bottom
			img.set_pixel(7 - t, i, COLOR_SHADOW)     # right
	_hidden_style = StyleBoxTexture.new()
	_hidden_style.texture = ImageTexture.create_from_image(img)
	_hidden_style.set_texture_margin_all(2)

	_hidden_pressed_style = _flat(COLOR_FACE, COLOR_SHADOW, 1)
	_revealed_style = _flat(COLOR_FACE, COLOR_SHADOW, 1)

func _flat(fill: Color, border: Color, width: int) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = fill
	s.border_color = border
	s.set_border_width_all(width)
	return s

func _make_cell() -> Button:
	var b := Button.new()
	b.custom_minimum_size = Vector2(40, 67.5)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_stylebox_override("normal", _hidden_style)
	b.add_theme_stylebox_override("hover", _hidden_style)
	b.add_theme_stylebox_override("pressed", _hidden_pressed_style)
	b.add_theme_font_size_override("font_size", 44)
	return b

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
			cell.add_theme_stylebox_override("normal", _revealed_style)
			cell.add_theme_stylebox_override("hover", _revealed_style)
			if n > 0:
				cell.text = str(n)
				cell.add_theme_color_override("font_color", NUM_COLORS[n])
				cell.add_theme_color_override("font_disabled_color", NUM_COLORS[n])
