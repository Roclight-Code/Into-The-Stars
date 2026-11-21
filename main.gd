extends Node3D

@export var sonar: Control

@onready var console: Node3D = $Console
@onready var rover: Node3D = $Rover

func _ready() -> void:
	console.connect_rover(rover)
	sonar.target = rover
