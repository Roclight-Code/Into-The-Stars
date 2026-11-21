extends Node3D

@onready var console: Node3D = $Console
@onready var rover: Node3D = $Rover

func _ready() -> void:
	console.connect_rover(rover)
