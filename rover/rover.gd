extends CharacterBody3D

@export var move_speed := 3.0
@export var turn_speed := 1.5   # radians per second

var generator: Node3D

# -1, 0, or 1
var drive_input := 0.0

func has_power() -> bool:
	return generator == null or generator.can_use_rover()

func _physics_process(_delta: float) -> void:
	var moving := drive_input != 0.0 and has_power()
	if generator:
		generator.driving = moving
	if not moving:
		return
	# Forward is -Z in the rover's own orientation
	velocity = -global_transform.basis.z * drive_input * move_speed
	move_and_slide()

func set_steering(on: bool) -> void:
	if generator:
		generator.steering = on

func connect_console(gen: Node3D, display: Control) -> void:
	generator = gen
	$LidarScanner.setup(gen, display)

# --- Called by the buttons ---

func _on_up_held() -> void:
	drive_input = 1.0

func _on_down_held() -> void:
	drive_input = -1.0

func _on_button_released() -> void:
	drive_input = 0.0

# Rotates in place, unless that would push the rover's shape into something.
# Returns whether it actually turned.
func turn(angle: float) -> bool:
	var rotated := Transform3D(global_transform.basis.rotated(Vector3.UP, angle), global_transform.origin)
	# If it's already overlapping (stuck), allow turning so the player can get out.
	if not _overlaps(global_transform) and _overlaps(rotated):
		return false
	global_transform = rotated
	return true

func _overlaps(t: Transform3D) -> bool:
	# A zero-length move with recovery counted as a collision reports any overlap.
	return test_move(t, Vector3.ZERO, null, 0.001, true)
