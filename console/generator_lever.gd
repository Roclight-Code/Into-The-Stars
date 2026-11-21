extends Pressable

@export var generator: Node3D
@export var rotation_axis := Vector3(1, 0, 0)
@export var on_angle := -30.0               # degrees, lever position when generator is ON
@export var off_angle := 30.0               # degrees, lever position when generator is OFF
@export var flip_time := 0.15

func _on_ready() -> void:
	_set_angle(on_angle if generator.is_on else off_angle, false)
	generator.power_changed.connect(_on_power_changed)

func get_prompt() -> String:
	return "Shut down generator" if generator.is_on else "Turn generator on"

func _on_pressed() -> void:
	generator.toggle_power()

func _on_power_changed(is_on: bool) -> void:
	_set_angle(on_angle if is_on else off_angle, true)

func _set_angle(deg: float, animate: bool) -> void:
	if _tween:
		_tween.kill()
	var target := rotation_axis.normalized() * deg_to_rad(deg)
	if animate:
		_tween = create_tween()
		_tween.tween_property(visual, "rotation", target, flip_time)
	else:
		visual.rotation = target
