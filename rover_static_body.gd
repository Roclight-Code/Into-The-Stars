extends StaticBody3D

@export var move_speed := 3.0
@export var turn_speed := 1.5   # radians per second
@export var generator: Node3D

# -1, 0, or 1 for each input
var drive_input := 0.0

func _physics_process(delta: float) -> void:
	if drive_input == 0.0 or not has_power():
		return
	# Forward is -Z in Godot
	translate(Vector3(0, 0, -drive_input * move_speed * delta))

# --- Called by the buttons and switch ---

func _on_up_held() -> void:
	drive_input = 1.0

func _on_down_held() -> void:
	drive_input = -1.0

func _on_button_released() -> void:
	drive_input = 0.0

func has_power() -> bool:
	return generator == null or generator.can_use_rover()
