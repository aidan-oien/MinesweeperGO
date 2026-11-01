extends Node3D

@export var camera_anchor: Marker3D

func _input( _event ):
	pass

func _ready() -> void:
	if !camera_anchor:
		push_error("camera_anchor not set!")
		get_tree().quit()
	
func _process( _delta: float ) -> void:
	pass
	
func _physics_process( _delta: float ) -> void:
	pass
