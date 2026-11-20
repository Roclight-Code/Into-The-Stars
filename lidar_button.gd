extends Pressable

@export var generator: Node3D
@export var rover: Node3D           # only needed if the click makes noise
@export var makes_noise := false

func _on_ready() -> void:
	if generator:
		generator.lidar_changed.connect(_on_lidar_changed)

func get_prompt() -> String:
	return "Turn lidar off" if generator.lidar_active else "Turn lidar on"

func _on_pressed() -> void:
	var want_on: bool = not generator.lidar_active
	if not generator.set_lidar(want_on) and want_on:
		_blip()          # refused: no power or locked out
		return
	if makes_noise and rover:
		NoiseBus.make_noise(rover.global_position, NoiseBus.Level.CLOSE)

func _on_lidar_changed(on: bool) -> void:
	_animate(on)         # also fires when the generator forces it off

func _blip() -> void:
	if not visual:
		return
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(visual, "position", _pressed_pos, press_time)
	_tween.tween_property(visual, "position", _rest_pos, press_time)
