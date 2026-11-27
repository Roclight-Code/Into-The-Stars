extends Node3D

@export_group("Idle (no unread messages)")
@export var idle_light_energy := 0.6
@export var idle_light_color := Color(0.2, 0.6, 0.4)
@export var emission_idle := 1.0

@export_group("Alert (unread message)")
@export var alert_light_energy := 4.0
@export var alert_light_color := Color(1.0, 0.6, 0.2)
@export var emission_alert := 2.5

@export_group("Other")
@export var fade_time := 0.4

@export_group("Debug")
@export var debug_unlock_key := false   # when on, pressing L unlocks the test logs

@onready var screen: MeshInstance3D = $Screen
@onready var viewport: SubViewport = $SubViewport
@onready var logs_display = $SubViewport/LogsDisplay
@onready var backlight: OmniLight3D = $BackLight
@onready var focus_point: Marker3D = $FocusPoint

var screen_material: StandardMaterial3D
var alert_on := false
var tween: Tween

var active := false   # true once the camera has arrived and clicks are forwarded
var _busy := false
var _player
var _cam: Camera3D
var _saved_cam_transform: Transform3D

var _psx_focus := 0.0
var _psx_tween: Tween

func _ready() -> void:
	screen_material = StandardMaterial3D.new()
	var tex := viewport.get_texture()
	screen_material.albedo_color = Color.BLACK
	screen_material.emission_enabled = true
	screen_material.emission_texture = tex
	screen_material.emission_energy_multiplier = emission_idle
	screen.material_override = screen_material

	backlight.light_energy = idle_light_energy
	backlight.light_color = idle_light_color

	logs_display.unread_changed.connect(_on_unread_changed)
	_on_unread_changed(logs_display.get_unread_total())
	logs_display.use_speaker($Speaker)

func _on_unread_changed(total: int) -> void:
	set_alert(total > 0)

func set_alert(on: bool) -> void:
	if on == alert_on:
		return
	alert_on = on
	if tween:
		tween.kill()
	tween = create_tween().set_parallel(true)
	tween.tween_property(backlight, "light_energy", alert_light_energy if on else idle_light_energy, fade_time)
	tween.tween_property(backlight, "light_color", alert_light_color if on else idle_light_color, fade_time)
	tween.tween_property(screen_material, "emission_energy_multiplier", emission_alert if on else emission_idle, fade_time)

func enter(player) -> void:
	if active or _busy:
		return
	_busy = true
	logs_display.console_entered()
	_player = player
	_cam = player.get_node("Head/Camera3D")
	_saved_cam_transform = _cam.transform
	player.controls_locked = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_fade_psx_focus(1.0)

	var start: Transform3D = _cam.global_transform
	var end: Transform3D = focus_point.global_transform
	var t := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_method(func(w): _cam.global_transform = start.interpolate_with(end, w), 0.0, 1.0, 0.4)
	await t.finished
	active = true
	_busy = false

func exit() -> void:
	if not active or _busy:
		return
	_busy = true
	logs_display.console_exited()
	active = false
	_fade_psx_focus(0.0)

	var start: Transform3D = _cam.global_transform
	var end: Transform3D = (_cam.get_parent() as Node3D).global_transform * _saved_cam_transform
	var t := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_method(func(w): _cam.global_transform = start.interpolate_with(end, w), 0.0, 1.0, 0.4)
	await t.finished
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_player.controls_locked = false
	_busy = false

func _fade_psx_focus(to: float) -> void:
	if _psx_tween:
		_psx_tween.kill()
	_psx_tween = create_tween()
	_psx_tween.tween_method(_set_psx_focus, _psx_focus, to, 0.4)

func _set_psx_focus(v: float) -> void:
	_psx_focus = v
	RenderingServer.global_shader_parameter_set("psx_focus", v)

func _input(event: InputEvent) -> void:
	if not active:
		return
	if event.is_action_pressed("ui_cancel"):
		exit()
		get_viewport().set_input_as_handled()
		return
	if event is InputEventMouse:
		var pos = _mouse_to_viewport(event.position)
		if pos == null:
			return
		var forwarded: InputEventMouse = event.duplicate()
		forwarded.position = pos
		forwarded.global_position = pos
		viewport.push_input(forwarded)
		get_viewport().set_input_as_handled()

func _mouse_to_viewport(mouse: Vector2) -> Variant:
	var cam := get_viewport().get_camera_3d()
	if cam == null:
		return null
	var inv := screen.global_transform.affine_inverse()
	var origin: Vector3 = inv * cam.project_ray_origin(mouse)
	var dir: Vector3 = inv.basis * cam.project_ray_normal(mouse)
	if absf(dir.z) < 0.0001:
		return null
	var t := -origin.z / dir.z
	if t < 0.0:
		return null
	var hit := origin + dir * t
	var quad_size: Vector2 = (screen.mesh as QuadMesh).size
	var uv := Vector2(hit.x / quad_size.x + 0.5, 0.5 - hit.y / quad_size.y)
	if uv.x < 0.0 or uv.x > 1.0 or uv.y < 0.0 or uv.y > 1.0:
		return null
	return uv * Vector2(viewport.size)

func _unhandled_input(event: InputEvent) -> void:
	if not debug_unlock_key:
		return
	if event is InputEventKey and event.pressed and event.keycode == KEY_L:
		for path in [
			"res://logs/data/emails/generator_check.tres",
			"res://logs/data/audio/test_audio_log.tres",
			"res://logs/data/creatures/watcher.tres",
		]:
			LogDatabase.add_log(load(path))
