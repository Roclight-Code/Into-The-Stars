extends StaticBody3D

signal held
signal released

@export var rover: Node3D   # drag RoverStaticBody into this in the Inspector

var is_held := false
var noise_timer := 0.0

const NOISE_INTERVAL := 0.5

func _process(delta: float) -> void:
	if is_held and rover:
		noise_timer += delta
		if noise_timer >= NOISE_INTERVAL:
			noise_timer = 0.0
			NoiseBus.make_noise(rover.global_position, NoiseBus.Level.CLOSE)

func get_prompt() -> String:
	return "Hold"

func interact(_player) -> void:
	pass

func hold(_player) -> void:
	if not is_held and rover:
		NoiseBus.make_noise(rover.global_position, NoiseBus.Level.CLOSE)
		noise_timer = 0.0
	is_held = true
	held.emit()
	if not is_held and rover:
		NoiseBus.make_noise(rover.global_position, NoiseBus.Level.CLOSE)
	is_held = true
	held.emit()

func release(_player) -> void:
	is_held = false
	released.emit()
