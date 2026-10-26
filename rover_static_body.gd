extends StaticBody3D

@export var button: StaticBody3D  # drag the button here in the Inspector
@export var speed := 2.0

func _process(delta: float) -> void:
	if button and button.is_held:
		global_position -= global_transform.basis.z * speed * delta
