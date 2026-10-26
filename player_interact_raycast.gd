extends RayCast3D

var current: Object = null

func _physics_process(_delta: float) -> void:
	var target = get_collider() if is_colliding() else null

	# Looked away from the button: release it
	if target != current:
		if current and current.has_method("set_held"):
			current.set_held(false)
		current = target

	# Hold E while looking at the button
	if current and current.has_method("set_held"):
		current.set_held(Input.is_action_pressed("interact"))
