extends Pressable

signal toggled(is_on: bool)

@export var generator: Node3D
@export var rover: Node3D           # only needed if the click makes noise
@export var makes_noise := false

var is_on := false

func _on_ready() -> void:
	if generator:
		generator.lidar_forced_off.connect(_on_forced_off)

func get_prompt() -> String:
	return "Turn lidar off" if is_on else "Turn lidar on"

func _on_pressed() -> void:
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

func _on_forced_off() -> void:
	is_on = false
	_animate(false)
	toggled.emit(false)

func _blip() -> void:
	if not visual:
		return
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(visual, "position", _pressed_pos, press_time)
	_tween.tween_property(visual, "position", _rest_pos, press_time)
