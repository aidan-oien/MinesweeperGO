class_name TileManager
extends Node3D

const ZOOM := 18
const RADIUS := 3                      
const WORLD_SCALE := 0.05              
const TILE_URL := "https://tile.openstreetmap.org/{z}/{x}/{y}.png"
const USER_AGENT := "MinesweeperGO/0.1 (seinayz@gmail.com)"   # this is my email (Josh) just @ me if smthn is wrong cuz of this line
const MAX_CONCURRENT := 4

var _origin_x := 0.0                   
var _origin_y := 0.0
var _units_per_tile := 1.0             
var _tiles := {}                       
var _queue: Array[Vector2i] = []
var _active := 0
var _center := Vector2i(-999999, -999999)
var _origin_set := false

func _tile_x(lon: float) -> float:
	return (lon + 180.0) / 360.0 * pow(2.0, ZOOM)

func _tile_y(lat: float) -> float:
	var r := deg_to_rad(lat)
	return (1.0 - log(tan(r) + 1.0 / cos(r)) / PI) / 2.0 * pow(2.0, ZOOM)

func set_origin(lat: float, lon: float) -> void:
	for t in _tiles.values():
		t.queue_free()
	_tiles.clear()
	_queue.clear()
	
	_origin_x = _tile_x(lon)
	_origin_y = _tile_y(lat)
	_units_per_tile = 40075016.686 * cos(deg_to_rad(lat)) / pow(2.0, ZOOM) * WORLD_SCALE
	_center = Vector2i(-999999, -999999)
	_origin_set = true

func latlon_to_world(lat: float, lon: float) -> Vector3:
	return Vector3(
		(_tile_x(lon) - _origin_x) * _units_per_tile,
		0.0,
		(_tile_y(lat) - _origin_y) * _units_per_tile)

func update_center(world_pos: Vector3) -> void:
	if not _origin_set:
		return
	
	var tx := _origin_x + world_pos.x / _units_per_tile
	var ty := _origin_y + world_pos.z / _units_per_tile
	var c := Vector2i(floori(tx), floori(ty))
	if c == _center:
		return
	_center = c

	var wanted := {}
	for dy in range(-RADIUS, RADIUS + 1):
		for dx in range(-RADIUS, RADIUS + 1):
			wanted[Vector2i(c.x + dx, c.y + dy)] = true

	for key in _tiles.keys():            
		if not wanted.has(key):
			_tiles[key].queue_free()
			_tiles.erase(key)

	var new_keys: Array[Vector2i] = []   
	for key in wanted.keys():
		if not _tiles.has(key):
			_spawn_tile(key)
			new_keys.append(key)

	new_keys.sort_custom(func(a, b): return a.distance_squared_to(c) < b.distance_squared_to(c))
	_queue.append_array(new_keys)

func _spawn_tile(key: Vector2i) -> void:
	var quad := QuadMesh.new()
	quad.size = Vector2(_units_per_tile, _units_per_tile)

	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(0.55, 0.6, 0.55)        # placeholder image
	mat.texture_repeat = false                        
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC

	var mi := MeshInstance3D.new()
	mi.mesh = quad
	mi.material_override = mat
	mi.rotation_degrees.x = -90.0                     
	mi.position = Vector3(
		(key.x + 0.5 - _origin_x) * _units_per_tile,
		0.0,
		(key.y + 0.5 - _origin_y) * _units_per_tile)
	add_child(mi)
	_tiles[key] = mi

func _process(_delta: float) -> void:
	while _active < MAX_CONCURRENT and not _queue.is_empty():
		var key: Vector2i = _queue.pop_front()
		if _tiles.has(key):
			_fetch(key)

func _cache_path(key: Vector2i) -> String:
	return "user://tiles/%d/%d/%d.png" % [ZOOM, key.x, key.y]

func _fetch(key: Vector2i) -> void:
	var max_index := (1 << ZOOM) - 1
	if key.x < 0 or key.x > max_index or key.y < 0 or key.y > max_index:
		return
		
	var path := _cache_path(key)
	if FileAccess.file_exists(path):
		var cached := Image.load_from_file(path)
		if cached != null:
			_apply(key, cached)
			return

	var req := HTTPRequest.new()
	add_child(req)
	req.request_completed.connect(_on_downloaded.bind(req, key))
	var url := TILE_URL.format({"z": ZOOM, "x": key.x, "y": key.y})
	if req.request(url, ["User-Agent: " + USER_AGENT]) != OK:
		req.queue_free()
		return
	_active += 1

func _on_downloaded(result: int, code: int, _headers: PackedStringArray,
		body: PackedByteArray, req: HTTPRequest, key: Vector2i) -> void:
	_active -= 1
	req.queue_free()
	if result != HTTPRequest.RESULT_SUCCESS or code != 200:
		push_warning("Tile %s failed (result %d, HTTP %d)" % [key, result, code])
		return

	var img := Image.new()
	if img.load_png_from_buffer(body) != OK:
		return

	var path := _cache_path(key)
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f:
		f.store_buffer(body)
		f.close()
	_apply(key, img)

func _apply(key: Vector2i, img: Image) -> void:
	if not _tiles.has(key):              
		return
	img.generate_mipmaps()
	var mat: StandardMaterial3D = _tiles[key].material_override
	mat.albedo_texture = ImageTexture.create_from_image(img)
	mat.albedo_color = Color.WHITE
