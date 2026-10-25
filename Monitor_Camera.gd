extends Camera3D

@export var max_speed: float = 3.0

# How quickly the camera reaches top speed, in units per second squared.
# Higher = snappier, lower = floaty and gradual.
@export var acceleration: float = 10.0

# How quickly it slows to a stop when nothing is pressed.
@export var deceleration: float = 8.0

# If true, "forward" follows where the camera faces (flattened to the ground).
# If false, directions are fixed world axes.
@export var relative_to_camera: bool = true

# Every direction currently being requested (for example, forward AND left held together).
var _active_dirs: Array[Vector3] = []

# The camera's current velocity (direction and speed combined).
var _velocity: Vector3 = Vector3.ZERO

# Called by a button when it should START pushing the camera.
func start_moving(dir: Vector3) -> void:
	# Only add it if it isn't already there, so it can't be counted twice.
	if not _active_dirs.has(dir):
		_active_dirs.append(dir)

# Called by a button when it should STOP pushing the camera.
func stop_moving(dir: Vector3) -> void:
	_active_dirs.erase(dir)

# Runs every frame. "delta" is the time since the last frame in seconds.
# Multiplying by delta keeps movement the same speed at any frame rate.
func _process(delta: float) -> void:
	# Add up all active directions into one combined direction.
	var input_dir := Vector3.ZERO
	for d in _active_dirs:
		input_dir += d

	# Convert the local direction into a world direction if needed.
	if relative_to_camera:
		# Rotate the input by the camera's rotation, then flatten it
		# so looking slightly downward doesn't make the camera sink.
		input_dir = global_transform.basis * input_dir
		input_dir.y = 0.0

	# normalized() makes the length 1, so moving diagonally isn't faster.
	input_dir = input_dir.normalized()

	# The velocity we WANT to reach this frame.
	var target_velocity := input_dir * max_speed

	# Pick speeding up or slowing down depending on whether anything is pressed.
	var rate := acceleration if input_dir != Vector3.ZERO else deceleration

	# move_toward nudges the velocity toward the target by at most rate * delta.
	# This gives the smooth ease in and ease out.
	_velocity = _velocity.move_toward(target_velocity, rate * delta)

	# Finally, move the camera by velocity * delta.
	global_position += _velocity * delta
func _unhandled_input(event: InputEvent) -> void: #THIS IS THE SECTION FOR
	# Pressing a key starts that direction, releasing it stops that direction.
	if event.is_action_pressed("ui_up"):
		start_moving(Vector3.FORWARD)
	elif event.is_action_released("ui_up"):
		stop_moving(Vector3.FORWARD)
	if event.is_action_pressed("ui_down"):
		start_moving(Vector3.BACK)
	elif event.is_action_released("ui_down"):
		stop_moving(Vector3.BACK)
	if event.is_action_pressed("ui_left"):
		start_moving(Vector3.LEFT)
	elif event.is_action_released("ui_left"):
		stop_moving(Vector3.LEFT)
	if event.is_action_pressed("ui_right"):
		start_moving(Vector3.RIGHT)
	elif event.is_action_released("ui_right"):
		stop_moving(Vector3.RIGHT)
