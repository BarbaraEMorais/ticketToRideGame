extends Sprite2D

@export var background_scale_factor: float = 1.1
@export var background_color: Color = Color.WHITE

func create_background():
	var background = ColorRect.new()
	background.color = Color.WHITE
	
	var bg_size = texture.get_size() * scale * background_scale_factor
	background.size = bg_size
	background.position = position - (bg_size / 2)
	
	add_child(background)
	background.z_index = -1
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
