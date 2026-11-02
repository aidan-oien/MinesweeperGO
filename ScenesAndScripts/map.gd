extends Node3D

@export var camera_anchor: Marker3D

var is_screen_touched : bool
var camera_vel : float

func _input( event ):
	if event is InputEventScreenDrag:
		print(event.relative.x)
		camera_anchor.rotation.y -= event.relative.x / 200
		camera_vel = event.relative.x
		if camera_vel == 1.0 or camera_vel == -1.0:
			camera_vel = 0
	
	if event is InputEventScreenTouch:
		is_screen_touched = !is_screen_touched
		if is_screen_touched:
			camera_vel = 0.0

func _ready() -> void:
	if !camera_anchor:
		push_error("camera_anchor not set!")
		get_tree().quit()
	
func _process( _delta: float ) -> void:
	pass
	
func _physics_process( _delta: float ) -> void:
	if camera_vel != 0 and !is_screen_touched:
		camera_anchor.rotation.y -= camera_vel / 200
		camera_vel = lerp( camera_vel, 0.0, 0.025)
		#if ((int) ( camera_vel * 100 )) / 100.0 == 0:
			#camera_vel = 0.0;
		print(camera_vel)
