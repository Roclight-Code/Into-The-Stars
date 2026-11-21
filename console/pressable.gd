class_name Pressable
extends StaticBody3D

@export var visual: Node3D
## How far the visual moves when pressed, in this button's local space.
@export var press_offset := Vector3(0.0, 0.0, 0.02)
@export var press_time := 0.06

var _rest_pos: Vector3
var _pressed_pos: Vector3
var _tween: Tween
var _latched := false

func _ready() -> void:
	if visual:
		_rest_pos = visual.position
		_pressed_pos = _rest_pos + press_offset
	_on_ready()

# Subclasses override these instead of _ready:
func _on_ready() -> void:
	pass

func _on_pressed() -> void:
	pass

# The interface the player calls
func get_prompt() -> String:
	return ""

func interact(_player) -> void:
	pass

# Default behaviour: trigger _on_pressed() once per press
func hold(_player) -> void:
	if _latched:
		return
	_latched = true
	_on_pressed()

func release(_player) -> void:
	_latched = false

# Shared animation
func _animate(pressed_down: bool) -> void:
	if not visual:
		return
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(visual, "position", _pressed_pos if pressed_down else _rest_pos, press_time)
