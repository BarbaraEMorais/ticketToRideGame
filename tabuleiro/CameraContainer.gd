extends Container

@onready var camera: Camera2D = $Camera2D

func _input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			# Zoom in
			var new_zoom_x = camera.zoom.x - camera.zoom_speed
			var new_zoom_y = camera.zoom.y - camera.zoom_speed
			camera.zoom.x = max(camera.min_zoom, new_zoom_x)
			camera.zoom.y = max(camera.min_zoom, new_zoom_y)
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			# Zoom out
			var new_zoom_x = camera.zoom.x + camera.zoom_speed
			var new_zoom_y = camera.zoom.y + camera.zoom_speed
			camera.zoom.x = min(camera.max_zoom, new_zoom_x)
			camera.zoom.y = min(camera.max_zoom, new_zoom_y)

	if event is InputEventMouseMotion and event.button_mask == MOUSE_BUTTON_MASK_LEFT:
		camera.position -= event.relative / camera.zoom.x
