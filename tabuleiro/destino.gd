class_name Destino extends Area2D

signal destination_clicked(destination_id: int, destination_name_val: String, node_instance: Area2D)

@export var destination_id: int = 0
@export var destination_name: String = "Unnamed Destination" : set = set_destination_name
@export var map_x: float = 0.0
@export var map_y: float = 0.0

@onready var sprite_node: Sprite2D = $Sprite2D
@onready var label_node: Label = $Label

func _ready():
    self.position = Vector2(map_x, map_y)

    if label_node:
        label_node.text = destination_name
    else:
        push_warning("Destination.gd: Label node not found or not named 'Label'.")


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
    """Handles input events on the Area2D."""
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
            print("Clicked on Destination: ID - %s, Name - '%s' at %s" % [destination_id, destination_name, position])
            emit_signal("destination_clicked", destination_id, destination_name, self)
            get_viewport().set_input_as_handled()


func set_destination_name(new_name: String):
    destination_name = new_name
    if label_node:
        label_node.text = destination_name
    elif is_inside_tree() and get_node_or_null("Label"):
        get_node("Label").text = destination_name


func setup_data(id_val: int, name_val: String, pos_val: Vector2):
    destination_id = id_val
    set_destination_name(name_val)

    map_x = pos_val.x
    map_y = pos_val.y
    self.position = pos_val

    if not is_node_ready() or not label_node:
        var lbl = get_node_or_null("Label")
        if lbl:
            lbl.text = name_val
    elif label_node:
        label_node.text = name_val
