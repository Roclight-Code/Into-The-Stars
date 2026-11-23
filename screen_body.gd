extends StaticBody3D

func get_prompt() -> String:
	return "Read messages"

func interact(player) -> void:
	get_parent().enter(player)
