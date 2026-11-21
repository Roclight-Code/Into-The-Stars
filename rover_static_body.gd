extends StaticBody3D

@export var move_speed := 3.0
@export var turn_speed := 1.5   # radians per second
@export var generator: Node3D

# -1, 0, or 1
var drive_input := 0.0

func has_power() -> bool:
	return generator == null or generator.can_use_rover()

func _physics_process(delta: float) -> void:
	var moving := drive_input != 0.0 and has_power()
	if generator:
		generator.driving = moving
	if not moving:
		return
	# Forward is -Z in Godot
	translate(Vector3(0, 0, -drive_input * move_speed * delta))

func set_steering(on: bool) -> void:
	if generator:
		generator.steering = on

# --- Called by the buttons ---

func _on_up_held() -> void:
	drive_input = 1.0

func _on_down_held() -> void:
	drive_input = -1.0

func _on_button_released() -> void:
	drive_input = 0.0
