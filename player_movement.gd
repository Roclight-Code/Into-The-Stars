extends CharacterBody3D

@export var speed := 5.0
@export var jump_velocity := 4.5
@export var mouse_sensitivity := 0.003

@export_group("Sitting")
@export var sit_yaw_limit := 70.0
@export var sit_pitch_min := -50.0
@export var sit_pitch_max := 40.0
@export var sit_transition_time := 0.35

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var head: Node3D = $Head
@onready var ray: RayCast3D = $Head/Camera3D/InteractRay
@onready var prompt: Label = $HUD/PromptLabel
@onready var reticle: ColorRect = $HUD/Reticle
@onready var body_collision: CollisionShape3D = $CollisionShape3D

var current_target: Node = null
var held_target: Node = null
var sitting := false
var current_seat: Node3D = null
var _transitioning := false

var held_button: Node = null   # top of the script, with your other variables

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	ray.add_exception(self)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var dx: float = event.relative.x * mouse_sensitivity
		var dy: float = event.relative.y * mouse_sensitivity
		if _transitioning:
			pass
		elif sitting:
			# Body stays locked to the seat; only the head turns, within limits
			head.rotation.y = clampf(head.rotation.y - dx,
					-deg_to_rad(sit_yaw_limit), deg_to_rad(sit_yaw_limit))
			head.rotation.x = clampf(head.rotation.x - dy,
					deg_to_rad(sit_pitch_min), deg_to_rad(sit_pitch_max))
		else:
			rotate_y(-dx)
			head.rotate_x(-dy)
			head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if event.is_action_pressed("stand_up") and sitting:
		stand_up()

func _physics_process(delta: float) -> void:
	if not sitting and not _transitioning:
		if not is_on_floor():
			velocity.y -= gravity * delta

		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = jump_velocity

		var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)

		move_and_slide()


	if not _transitioning:
		#if ray.is_colliding():
			#var c := ray.get_collider()
			#print("Ray hit: ", c.name, " | has interact: ", c.has_method("interact"))
		_update_target()
		_handle_interact_input()

func _update_target() -> void:
	# While E is held on something, stay locked on it even if we look away
	if held_target:
		return
	var hit: Node = null
	if ray.is_colliding():
		var collider := ray.get_collider()
		# While seated, ignore the seat itself so it doesn't prompt "Sit"
		if collider and collider.has_method("interact") and not (sitting and collider == current_seat):
			hit = collider

	if hit != current_target:
		if current_target and is_instance_valid(current_target) and current_target.has_method("release"):
			current_target.release(self)
		current_target = hit

	if current_target:
		prompt.text = "[E] " + current_target.get_prompt()
		reticle.color = Color(1, 1, 0)
	else:
		prompt.text = ""
		reticle.color = Color(1, 1, 1)

func _handle_interact_input() -> void:
	# Something is held: it only lets go when E is released, wherever we're looking
	if held_target:
		if not is_instance_valid(held_target):
			held_target = null
		elif not Input.is_action_pressed("interact"):
			if held_target.has_method("release"):
				held_target.release(self)
			held_target = null
		elif held_target.has_method("hold"):
			held_target.hold(self)
		return

	if current_target == null:
		return

	if Input.is_action_just_pressed("interact"):
		current_target.interact(self)
		# Only things with hold() get locked on; seats and one-shot interactables don't
		if current_target.has_method("hold"):
			held_target = current_target

func sit_down(seat: Node3D) -> void:
	if sitting or _transitioning:
		return
	_transitioning = true
	current_seat = seat
	velocity = Vector3.ZERO
	body_collision.disabled = true

	var sit_point := seat.get_node_or_null("SitPoint") as Node3D
	var target: Node3D = sit_point if sit_point else seat

	# Keep the current look direction so the camera doesn't snap: fold head yaw into
	# the body, and leave pitch alone (clamped to seated limits).
	head.rotation.y = 0.0
	var pitch := clampf(head.rotation.x, deg_to_rad(sit_pitch_min), deg_to_rad(sit_pitch_max))

	var tween := create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", target.global_position, sit_transition_time)
	tween.tween_property(self, "global_rotation", target.global_rotation, sit_transition_time)
	tween.tween_property(head, "rotation:x", pitch, sit_transition_time)
	await tween.finished

	sitting = true
	_transitioning = false

func stand_up() -> void:
	if not sitting or _transitioning:
		return

	# let go of any held button/crank before standing
	if held_target:
		if is_instance_valid(held_target) and held_target.has_method("release"):
			held_target.release(self)
		held_target = null

	_transitioning = true

	# Carry the head's yaw over to the body so the view doesn't snap on standing
	rotate_y(head.rotation.y)
	head.rotation.y = 0.0

	var stand_point := current_seat.get_node_or_null("StandPoint") as Node3D
	var target_pos: Vector3 = stand_point.global_position if stand_point \
			else current_seat.global_position + current_seat.global_transform.basis.z * 0.8

	var tween := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", target_pos, sit_transition_time)
	await tween.finished

	body_collision.disabled = false
	sitting = false
	current_seat = null
	_transitioning = false
