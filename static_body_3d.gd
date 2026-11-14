extends StaticBody3D

signal held
signal released

@export var rover: Node3D        # drag RoverStaticBody into this in the Inspector
@export var visual: Node3D       # drag the button's MeshInstance3D into this
@export var press_depth := 0.02
@export var press_axis := Vector3(0, 0, 1)   # local direction "into" the console
@export var press_time := 0.06

var is_held := false
var noise_timer := 0.0
var _rest_pos: Vector3
var _tween: Tween

const NOISE_INTERVAL := 0.5

func _ready() -> void:
	if visual:
		_rest_pos = visual.position

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
	if not is_held:
		is_held = true
		noise_timer = 0.0
		_animate(true)
		if rover:
			NoiseBus.make_noise(rover.global_position, NoiseBus.Level.CLOSE)
	held.emit()

func release(_player) -> void:
	if not is_held:
		return   # ignore the "looked away" release for a button that wasn't pressed
	is_held = false
	_animate(false)
	released.emit()

func _animate(pressed_down: bool) -> void:
	if not visual:
		return
	if _tween:
		_tween.kill()
	_tween = create_tween()
	var target := _rest_pos + press_axis.normalized() * press_depth if pressed_down else _rest_pos
	_tween.tween_property(visual, "position", target, press_time)
