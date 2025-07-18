class_name Trilho extends Area2D

signal trilho_hovered(trilho: Trilho)
signal trilho_unhovered(trilho: Trilho)
signal trilho_clicked(trilho: Trilho)

var mouse_pressed_pos: Vector2 = Vector2.INF
var is_dragging: bool = false
const DRAG_THRESHOLD: float = 5.0

var _color_map: Dictionary = {
	"blue": 1,
	"orange": 2,
	"pink": 3,
	"red": 4,
	"green": 5,
	"black": 6,
	"yellow": 7,
	"dark_blue": 8,
	"white": 9,
	"grey": 10
}

@export_enum("blue", "orange", "pink", "red", "green", "black", "yellow", "dark_blue", "white", "grey") var track_color: String = "blue":
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


func claim(cor: String):
	is_taken = true
	match cor:
		"vermelho": track_color = "red"
		"verde": track_color = "green"
		"laranja": track_color = "orange"
		"amarelo": track_color = "yellow"
		"rosa": track_color = "pink"
		"preto": track_color = "black"
		"azul_claro": track_color = "light_blue"


func _update_sprite() -> void:
	var state_prefix: String = "trilhopreenchido" if is_taken else "trilhovazio"
	var color_suffix: String = str(_color_map.get(track_color, 1))

	var path: String = "res://assets/mapa/trilhos/%s%s.svg" % [state_prefix, color_suffix]

	# Load the texture
	var new_texture: Texture2D = load(path)
	if new_texture:
		sprite.texture = new_texture
	else:
		printerr("Failed to load track sprite: %s" % path)


func _on_mouse_entered() -> void:
	trilho_hovered.emit(self)


func _on_mouse_exited() -> void:
	trilho_unhovered.emit(self)


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				mouse_pressed_pos = event.position
				is_dragging = false
			elif not event.pressed:
				if not is_dragging:
					trilho_clicked.emit(self)
				mouse_pressed_pos = Vector2.INF

	elif event is InputEventMouseMotion:
		if mouse_pressed_pos != Vector2.INF:
			var distance_moved = mouse_pressed_pos.distance_to(event.position)
			if distance_moved > DRAG_THRESHOLD:
				is_dragging = true


func highlight():
	sprite.modulate = Color(2.0, 2.0, 2.0)


func unhighlight():
	sprite.modulate = Color(1.0, 1.0, 1.0)
