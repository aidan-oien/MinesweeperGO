extends Node

var last_orientation = "" 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process( _delta):
	var size = get_viewport().size
	var current_orientation = ""
	if size.x > size.y:
		current_orientation = "landscape"
	else:
		current_orientation = "portrait"
	
	if current_orientation != last_orientation:
		last_orientation = current_orientation
		on_orientation_changed(current_orientation)
	
func on_orientation_changed(orientation):
	if orientation == "portrait":
		print("Switched to portrait")
		get_window().content_scale_size = Vector2i(360, 640)
	if orientation == "landscape":
		print("Switched to landscape")
		get_window().content_scale_size = Vector2i(640, 360)
