extends Camera2D

@export var zoom_speed: float = 0.1
@export var min_zoom: float = 0.9
@export var max_zoom: float = 2.5

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			# Zoom in
			var new_zoom_x = zoom.x - zoom_speed
			var new_zoom_y = zoom.y - zoom_speed
			zoom.x = max(min_zoom, new_zoom_x)
			zoom.y = max(min_zoom, new_zoom_y)
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			# Zoom out
			var new_zoom_x = zoom.x + zoom_speed
			var new_zoom_y = zoom.y + zoom_speed
			zoom.x = min(max_zoom, new_zoom_x)
			zoom.y = min(max_zoom, new_zoom_y)

	if event is InputEventMouseMotion and event.button_mask == MOUSE_BUTTON_MASK_LEFT:
		position -= event.relative / zoom.x
