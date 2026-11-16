extends StaticBody3D

signal toggled(is_on: bool)

@export var generator: Node3D
@export var rover: Node3D           # only needed if the click makes noise
@export var visual: Node3D
@export var pressed_marker: Node3D
@export var press_time := 0.06
@export var makes_noise := false

var is_on := false
var _rest_pos: Vector3
var _pressed_pos: Vector3
var _tween: Tween

func _ready() -> void:
	if visual:
		_rest_pos = visual.position
		_pressed_pos = _rest_pos
		if pressed_marker:
			var parent := visual.get_parent() as Node3D
			_pressed_pos = parent.to_local(pressed_marker.global_position)
	if generator:
		generator.lidar_forced_off.connect(_on_forced_off)

func get_prompt() -> String:
	return "Turn lidar off" if is_on else "Turn lidar on"

func interact(_player) -> void:
	pass

var _latched := false   # NEW: true while E is held after the toggle

func hold(_player) -> void:
	if _latched:
		return
	_latched = true

	var want_on := not is_on
	var allowed: bool = generator.set_lidar(want_on)

	if want_on and not allowed:
		_blip()
		return

	is_on = want_on
	_animate(is_on)
	if makes_noise and rover:
		NoiseBus.make_noise(rover.global_position, NoiseBus.Level.CLOSE)
	toggled.emit(is_on)

func release(_player) -> void:
	_latched = false

func _on_forced_off() -> void:
	is_on = false
	_animate(false)
	toggled.emit(false)

func _animate(pressed_down: bool) -> void:
	if not visual:
		return
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(visual, "position", _pressed_pos if pressed_down else _rest_pos, press_time)

func _blip() -> void:
	if not visual:
		return
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(visual, "position", _pressed_pos, press_time)
	_tween.tween_property(visual, "position", _rest_pos, press_time)
