class_name Trilho extends Area2D



var _color_map: Dictionary = {
	"Blue": 1,
	"Orange": 2,
	"Pink": 3,
	"Red": 4,
	"Green": 5,
	"DarkGray": 6,
	"Yellow": 7,
	"DarkBlue": 8
}


@export_enum("Blue", "Orange", "Pink", "Red", "Green", "DarkGray", "Yellow", "DarkBlue") var track_color: String = "Blue":
	set(value):
		track_color = value
		_update_sprite()

@export var is_taken: bool = false:
	set(value):
		is_taken = value
		_update_sprite()

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape_node: CollisionShape2D = $CollisionShape2D

@export var rectangle_color: Color = Color.WHITE
@export var linha: int


func _ready() -> void:
	if not sprite:
		push_warning("Sprite2D node not found.")
		return
	if not collision_shape_node:
		push_warning("CollisionShape2D node not found.")
		return
	if not collision_shape_node.shape:
		push_warning("CollisionShape2D does not have a shape assigned.")
		return

	_update_sprite()


func _update_sprite() -> void:
	var state_prefix: String = "trilhopreenchido" if is_taken else "trilhovazio"
	var color_suffix: String = str(_color_map.get(track_color, 1)) # Default to 1 if color not found

	var path: String = "res://assets/trilhos/%s%s.svg" % [state_prefix, color_suffix]

	# Load the texture
	var new_texture: Texture2D = load(path)
	if new_texture:
		sprite.texture = new_texture
	else:
		# Handle cases where the texture might not be found (e.g., wrong path, missing file)
		printerr("Failed to load track sprite: %s" % path)


func _on_mouse_entered() -> void:
	pass # Replace with function body.
