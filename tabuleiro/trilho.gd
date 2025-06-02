class_name Trilho extends Area2D

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

    if collision_shape_node.shape is RectangleShape2D:
        var rect_shape: RectangleShape2D = collision_shape_node.shape
        var shape_size: Vector2 = rect_shape.size

        if shape_size.x <= 0 or shape_size.y <= 0:
            push_warning("CollisionShape2D size is invalid for creating a texture.")
            return

        var image = Image.create(int(shape_size.x), int(shape_size.y), false, Image.FORMAT_RGBA8)
        image.fill(rectangle_color)
        var texture = ImageTexture.create_from_image(image)
        sprite.texture = texture

    else:
        push_warning("CollisionShape2D is not a RectangleShape2D. Cannot match sprite to its size.")
