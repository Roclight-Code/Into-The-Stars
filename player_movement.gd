extends CharacterBody3D
 
@export var speed := 5.0
@export var jump_velocity := 4.5
@export var mouse_sensitivity := 0.003

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var head: Node3D = $Head
@onready var ray: RayCast3D = $Head/Camera3D/InteractRay
@onready var prompt: Label = $HUD/PromptLabel
@onready var reticle: ColorRect = $HUD/Reticle

var current_target: Node = null

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	ray.add_exception(self)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
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

	_update_target()
	_handle_interact_input()

func _update_target() -> void:
	var hit: Node = null
	if ray.is_colliding():
		var collider := ray.get_collider()
		if collider and collider.has_method("interact"):
			hit = collider

	# If we looked away from a held button, release it
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
	if current_target == null:
		return

	if Input.is_action_just_pressed("interact"):
		current_target.interact(self)

	if current_target.has_method("hold"):
		if Input.is_action_pressed("interact"):
			current_target.hold(self)
		if Input.is_action_just_released("interact"):
			if current_target.has_method("release"):
				current_target.release(self)
