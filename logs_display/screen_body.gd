extends StaticBody3D

func get_prompt() -> String:
	return "Read messages"

func interact(player) -> void:
	# Find the monitor this collider belongs to, wherever it sits in the scene.
	var node := get_parent()
	while node != null and not node.has_method("enter"):
		node = node.get_parent()
	if node == null:
		push_warning("ScreenBody '%s' is not inside a monitor that has enter()" % get_path())
		return
	node.enter(player)
