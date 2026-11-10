extends StaticBody3D

@export var prompt_text := "Sit"

func get_prompt() -> String:
	return prompt_text

func interact(player: Node) -> void:
	player.sit_down(self)
