extends Node

enum Level { SILENT, VERY_CLOSE, CLOSE, FAR }

# Set these to the same world-space radii your minimap rings represent.
const RANGES := {
	Level.VERY_CLOSE: 3.0,
	Level.CLOSE: 8.0,
	Level.FAR: 15.0,
}

signal noise_made(position: Vector3, level: Level)

func make_noise(position: Vector3, level: Level) -> void:
	if level == Level.SILENT:
		return  # dead silent: nothing happens, nobody is notified

	noise_made.emit(position, level)
	# ...the rest of the function stays the same

	# Notify every listener in range
	var radius: float = RANGES[level]
	for listener in get_tree().get_nodes_in_group("noise_listeners"):
		if listener.global_position.distance_to(position) <= radius:
			listener.hear_noise(position, level)
