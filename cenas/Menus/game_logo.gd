extends TextureRect

@export var amplitude: float = 15.0
@export var speed: float = 2.0

var initial_position: Vector2
var initial_rotation: float
var time_passed: float = 0.0

func _ready():
	initial_position = position


func _process(delta: float):
	time_passed += delta

	var new_y = initial_position.y + sin(time_passed * speed) * amplitude

	position = Vector2(initial_position.x, new_y)
	rotation = sin(time_passed * 0.5) * 0.1 + 0.2
