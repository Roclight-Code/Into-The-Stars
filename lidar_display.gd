extends Control

@export var grid_width: int = 64   # keep in sync with the scanner
@export var grid_height: int = 36
@export var dot_color: Color = Color(0.3, 1.0, 0.45)

var _positions := PackedVector2Array()
var _brightness := PackedFloat32Array()

func set_dots(positions: PackedVector2Array, brightness: PackedFloat32Array) -> void:
	_positions = positions
	_brightness = brightness
	queue_redraw()

func clear_dots() -> void:
	_positions = PackedVector2Array()
	_brightness = PackedFloat32Array()
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color.BLACK)  # dark screen

	var cell := Vector2(size.x / grid_width, size.y / grid_height)
	var dot_size := cell * 0.6

	for i in _positions.size():
		var c := dot_color
		c.a = clampf(_brightness[i], 0.05, 1.0)  # dim = far
		var center := _positions[i] * size
		draw_rect(Rect2(center - dot_size * 0.5, dot_size), c)
