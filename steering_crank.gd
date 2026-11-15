extends StaticBody3D

@onready var focus_point: Marker3D = $FocusPoint

var focused := false
var _player
var _cam: Camera3D
var _saved_cam_transform: Transform3D
var _busy := false

func get_prompt() -> String:
	return "Use crank [E]"

func interact(player) -> void:
	if focused or _busy:
		return
	_enter_focus(player)

func _unhandled_input(event):
	if focused and not _busy and event.is_action_pressed("ui_cancel"):
		_exit_focus()

func _enter_focus(player) -> void:
	_busy = true
	_player = player
	_cam = player.get_node("Head/Camera3D")
	_saved_cam_transform = _cam.transform          # local to Head
	player.controls_locked = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var start := _cam.global_transform
	var end := focus_point.global_transform
	var t := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_method(func(w): _cam.global_transform = start.interpolate_with(end, w), 0.0, 1.0, 0.4)
	await t.finished
	focused = true
	_busy = false

func _exit_focus() -> void:
	_busy = true
	focused = false
	var start := _cam.global_transform
	var end: Transform3D = (_cam.get_parent() as Node3D).global_transform * _saved_cam_transform
	var t := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_method(func(w): _cam.global_transform = start.interpolate_with(end, w), 0.0, 1.0, 0.4)
	await t.finished
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_player.controls_locked = false
	_busy = false
