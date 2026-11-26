extends Node3D

# lat: 28.6024, lon: -81.2001 for UCF. these consts r just 4 debugging
const START_LAT := 28.6024
const START_LON := -81.2001
const DEBUG_SPEED := 0.5       
const MAX_ACCURACY_M := 50.0 

@export var camera_anchor: Marker3D
@export var tiles: TileManager
@export var player: Node3D

var is_screen_touched := false
var camera_vel := 0.0
var target_pos := Vector3.ZERO

var gps_provider = null
var has_first_fix := false
var debug_label: Label

func _input( event ):
	if event is InputEventScreenDrag:
		print(event.relative.x)
		camera_anchor.rotation.y -= event.relative.x / 200
		camera_vel = event.relative.x
		if camera_vel <= 1.0 and camera_vel >= -1.0:
			camera_vel = 0
	elif event is InputEventScreenTouch:
		is_screen_touched = event.pressed
		if is_screen_touched:
			camera_vel = 0.0
	
func _ready() -> void:
	var missing := PackedStringArray()
	if camera_anchor == null: missing.append("camera_anchor")
	if tiles == null: missing.append("tiles")
	if player == null: missing.append("player")
	if not missing.is_empty():
		push_error("Not assigned in Inspector: " + ", ".join(missing))
		set_process(false)
		set_physics_process(false)
		set_process_input(false)
		return

	_make_debug_label()

	if OS.get_name() == "Android":
		_set_debug("Waiting for GPS")
		_setup_gps()
	else:
		# PC: start at the debug location and use the arrow keys.
		tiles.set_origin(START_LAT, START_LON)
		tiles.update_center(Vector3.ZERO)
	
func _process( _delta: float ) -> void:
	# PC-only stand-in for GPS. Movement is relative to where the camera faces.
	if not OS.has_feature("android"):
		var dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		var move := camera_anchor.global_transform.basis * Vector3(dir.x, 0.0, dir.y)
		target_pos += move * DEBUG_SPEED * _delta
		
	player.position = player.position.lerp(target_pos, 1.0 - exp(-8.0 * _delta))
	camera_anchor.position = player.position
	tiles.update_center(player.position)
	
func _physics_process( _delta: float ) -> void:
	if camera_vel != 0 and !is_screen_touched:
		camera_anchor.rotation.y -= camera_vel / 200
		camera_vel = lerp( camera_vel, 0.0, 0.025)
		#if ((int) ( camera_vel * 100 )) / 100.0 == 0:
			#camera_vel = 0.0;
		print(camera_vel)

func on_gps_update(lat: float, lon: float) -> void:
	target_pos = tiles.latlon_to_world(lat, lon)

func _setup_gps() -> void:
	get_tree().on_request_permissions_result.connect(_on_permission_result)
	if OS.request_permissions():          
		_enable_gps()

func _on_permission_result(permission: String, granted: bool) -> void:
	if permission == "android.permission.ACCESS_FINE_LOCATION":
		if granted:
			_enable_gps()
		else:
			_set_debug("Precise location permission denied")

func _enable_gps() -> void:
	if gps_provider != null:
		return
	if not Engine.has_singleton("PraxisMapperGPSPlugin"):
		_set_debug("GPS plugin not found (enabled? Gradle build on?)")
		return
	gps_provider = Engine.get_singleton("PraxisMapperGPSPlugin")
	gps_provider.onLocationUpdates.connect(_on_location)
	gps_provider.StartListening()

func _on_location(data: Dictionary) -> void:
	var lat := float(data.get("latitude", 0.0))
	var lon := float(data.get("longitude", 0.0))
	var acc := float(data.get("accuracy", 9999.0))
	_set_debug("lat %.5f\nlon %.5f\nacc %.0f m" % [lat, lon, acc])

	if acc > MAX_ACCURACY_M:
		return

	if not has_first_fix:
		# Center the whole map on the player's real location.
		has_first_fix = true
		tiles.set_origin(lat, lon)
		player.position = Vector3.ZERO
		target_pos = Vector3.ZERO
		camera_anchor.position = Vector3.ZERO
		tiles.update_center(Vector3.ZERO)
	else:
		target_pos = tiles.latlon_to_world(lat, lon)

func _make_debug_label() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 100
	add_child(layer)
	debug_label = Label.new()
	debug_label.position = Vector2(20, 230) 
	debug_label.add_theme_font_size_override("font_size", 26)
	debug_label.add_theme_color_override("font_outline_color", Color.BLACK)
	debug_label.add_theme_constant_override("outline_size", 6)
	layer.add_child(debug_label)

func _set_debug(text: String) -> void:
	if debug_label:
		debug_label.text = text
