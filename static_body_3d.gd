extends StaticBody3D

signal held
signal released

var is_held := false

func get_prompt() -> String:
	return "Hold"

func interact(_player) -> void:
	pass  # the player script calls hold() while E is down

func hold(_player) -> void:
	#print("button hold")
	is_held = true
	held.emit()

func release(_player) -> void:
	is_held = false
	released.emit()
