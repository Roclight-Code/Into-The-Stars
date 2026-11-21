extends StaticBody3D

signal cranked(angle_delta: float)
signal tier_changed(new_tier: int)   # 0 = stopped, 1 = slow, 2 = fast (used for noise/glow later)

@export var rover: Node3D                         # assign in the Inspector
@export var turn_rates := [0.0, 25.0, 70.0]       # degrees/sec for tier 0, 1, 2
@export var slow_enter := 0.25                    # crank revolutions/sec to count as slow
@export var fast_enter := 1.0                     # revolutions/sec to count as fast
@export var fast_exit := 0.8                      # drop below this to leave fast (prevents flicker)

@onready var focus_point: Marker3D = $FocusPoint
@onready var pivot: Node3D = $Pivot

const MIN_RADIUS_PX := 24.0
const WINDOW := 0.1   # seconds of history used to measure speed

var focused := false
var dragging := false
var tier := 0
var _last_angle := 0.0
var _samples: Array = []   # each entry: [time_in_seconds, angle_delta]
var _player
var _cam: Camera3D
var _saved_cam_transform: Transform3D
var _busy := false

func get_prompt() -> String:
	return "Use crank"

func interact(player) -> void:
	if focused or _busy:
		return
	_enter_focus(player)

func _unhandled_input(event: InputEvent) -> void:
	if not focused or _busy:
		return

	if event.is_action_pressed("ui_cancel"):
		_exit_focus()
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var off: Vector2 = _cursor_offset()
			if off.length() > MIN_RADIUS_PX:
				dragging = true
				_last_angle = off.angle()
		else:
			_stop_drag()

	elif event is InputEventMouseMotion and dragging:
		var off: Vector2 = _cursor_offset()
		if off.length() < MIN_RADIUS_PX:
			return
		var a: float = off.angle()
		var d: float = wrapf(a - _last_angle, -PI, PI)
		_last_angle = a
		pivot.rotation.z -= d
		_samples.append([Time.get_ticks_msec() / 1000.0, d])
		cranked.emit(d)

func _process(delta: float) -> void:
	# Drop samples older than the window, then measure speed over what's left
	var now: float = Time.get_ticks_msec() / 1000.0
	while _samples.size() > 0 and now - _samples[0][0] > WINDOW:
		_samples.pop_front()

	var total := 0.0
	var net := 0.0
	for s in _samples:
		total += absf(s[1])
		net += s[1]
	var speed: float = total / TAU / WINDOW   # revolutions per second

	_update_tier(speed)

	var wants_turn: bool = tier > 0 and rover != null and rover.has_power()
	var turned := false
	if wants_turn:
		turned = rover.turn(-deg_to_rad(turn_rates[tier]) * signf(net) * delta)
	if rover:
		rover.set_steering(turned)

func _update_tier(speed: float) -> void:
	var t := 0
	if speed >= fast_enter or (tier == 2 and speed >= fast_exit):
		t = 2
	elif speed >= slow_enter:
		t = 1
	_set_tier(t)

func _set_tier(new_tier: int) -> void:
	if new_tier != tier:
		tier = new_tier
		tier_changed.emit(tier)

func _stop_drag() -> void:
	dragging = false
	_samples.clear()
	_set_tier(0)

func _cursor_offset() -> Vector2:
	var center: Vector2 = _cam.unproject_position(pivot.global_position)
	return get_viewport().get_mouse_position() - center

func _enter_focus(player) -> void:
	_busy = true
	_player = player
	_cam = player.get_node("Head/Camera3D")
	_saved_cam_transform = _cam.transform
	player.controls_locked = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var start: Transform3D = _cam.global_transform
	var end: Transform3D = focus_point.global_transform
	var t := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_method(func(w): _cam.global_transform = start.interpolate_with(end, w), 0.0, 1.0, 0.4)
	await t.finished
	focused = true
	_busy = false

func _exit_focus() -> void:
	_busy = true
	focused = false
	_stop_drag()
	var start: Transform3D = _cam.global_transform
	var end: Transform3D = (_cam.get_parent() as Node3D).global_transform * _saved_cam_transform
	var t := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_method(func(w): _cam.global_transform = start.interpolate_with(end, w), 0.0, 1.0, 0.4)
	await t.finished
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_player.controls_locked = false
	_busy = false
