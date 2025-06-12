class_name Parabola extends Node2D

@export var point_a: Vector2 = Vector2(-100, 0)
@export var point_b: Vector2 = Vector2(100, 0)
@export var convexity: float = -50.0  # Negative for upward curve, positive for downward
@export var line_color: Color = Color.WHITE
@export var margins: float = 0

func _init(a, b, conv, m = 0):
	set_points(a, b, m)
	set_convexity(conv)


func get_parabola_point(t: float) -> Vector2:
	# t ranges from 0 to 1
	# At t=0, we're at point_a
	# At t=1, we're at point_b
	# At t=0.5, we're at the vertex with convexity offset

	# Linear interpolation between the two points
	var base_point: Vector2 = point_a.lerp(point_b, t)

	# Calculate the parabolic offset
	# Uses the formula: offset = 4 * convexity * t * (1 - t)
	# This creates a parabolic curve that peaks at t=0.5
	var parabolic_offset: float = 4.0 * convexity * t * (1.0 - t)

	# Determine the direction perpendicular to the line between points
	var direction: Vector2 = (point_b - point_a).normalized()
	var perpendicular: Vector2 = Vector2(-direction.y, direction.x)

	# Apply the parabolic offset in the perpendicular direction
	return base_point + perpendicular * parabolic_offset


func get_tangent_vector_at_parameter(t: float) -> Vector2:
	t = clamp(t, 0.0, 1.0)

	# Calculate the tangent vector (derivative of the curve)
	var base_derivative: Vector2 = point_b - point_a
	var offset_derivative: float = 4.0 * convexity * (1.0 - 2.0 * t)
	var direction: Vector2 = (point_b - point_a).normalized()
	var perpendicular: Vector2 = Vector2(-direction.y, direction.x)

	var tangent_vector: Vector2 = base_derivative + perpendicular * offset_derivative
	return tangent_vector.normalized()  # Return as unit vector


func set_points(a: Vector2, b: Vector2, m: float):
	var margin = (b - a).normalized() * m

	point_a = a + margin
	point_b = b - margin


func set_convexity(new_convexity: float):
	convexity = new_convexity


func get_point_at_parameter(t: float) -> Vector2:
	return get_parabola_point(clamp(t, 0.0, 1.0))


func get_vertex() -> Vector2:
	return get_parabola_point(0.5)
