class_name HoldButton
extends Pressable

signal held
signal released

@export var rover: Node3D

const NOISE_INTERVAL := 0.5
var is_held := false
var _noise_timer := 0.0

func _on_ready() -> void:
	set_process(false)

func _process(delta: float) -> void:
	if rover:
		_noise_timer += delta
		if _noise_timer >= NOISE_INTERVAL:
			_noise_timer = 0.0
			NoiseBus.make_noise(rover.global_position, NoiseBus.Level.CLOSE)

func get_prompt() -> String:
	return "Hold"

func hold(_player) -> void:
	if not is_held:
		is_held = true
		_noise_timer = 0.0
		_animate(true)
		set_process(true)
		if rover:
			NoiseBus.make_noise(rover.global_position, NoiseBus.Level.CLOSE)
	held.emit()

func release(_player) -> void:
	if not is_held:
		return
	is_held = false
	_animate(false)
	set_process(false)
	released.emit()
