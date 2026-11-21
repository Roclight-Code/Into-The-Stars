extends Node3D

@export var forward_button: HoldButton
@export var back_button: HoldButton
@export var crank: Node3D
@export var generator: Node3D
@export var lidar_display: Control

# Called once by Main after everything has loaded.
func connect_rover(rover: Node3D) -> void:
	forward_button.rover = rover
	back_button.rover = rover
	crank.rover = rover
	forward_button.held.connect(rover._on_up_held)
	forward_button.released.connect(rover._on_button_released)
	back_button.held.connect(rover._on_down_held)
	back_button.released.connect(rover._on_button_released)
	rover.connect_console(generator, lidar_display)
