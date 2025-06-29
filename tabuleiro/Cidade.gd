class_name Cidade 
extends Area2D

signal cidade_clicked(cidade_id: int, cidade_name_val: String, node_instance: Area2D)

@export var cidade_id: int = 0
@export var cidade_name: String = "destino sem nome" : set = set_cidade_name
@export var map_x: float = 0.0
@export var map_y: float = 0.0

@onready var sprite_node: Sprite2D = $Sprite2D
@onready var label_node: Label = $PanelContainer/MarginContainer/Label

func _ready():
	self.position = Vector2(map_x, map_y)

	if label_node:
		label_node.text = cidade_name
	else:
		push_warning("Destination.gd: Label node not found or not named 'Label'.")


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	"""Handles input events on the Area2D."""
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("Clicked on Destination: ID - %s, Name - '%s' at %s" % [cidade_id, cidade_name, position])
			emit_signal("cidade_clicked", cidade_id, cidade_name, self)
			get_viewport().set_input_as_handled()


func set_cidade_name(new_name: String):
	cidade_name = new_name
	if label_node:
		label_node.text = cidade_name
	elif is_inside_tree() and get_node_or_null("Label"):
		get_node("Label").text = cidade_name


func setup_cidade(id_val: int, name_val: String, pos_val: Vector2):
	cidade_id = id_val
	set_cidade_name(name_val)

	map_x = pos_val.x
	map_y = pos_val.y
	self.position = pos_val

	if not is_node_ready() or not label_node:
		var lbl = get_node_or_null("Label")
		if lbl:
			lbl.text = name_val
	elif label_node:
		label_node.text = name_val
