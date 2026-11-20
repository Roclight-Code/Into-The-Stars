extends Node

enum Level { SILENT, VERY_CLOSE, CLOSE, FAR }

# Single source of truth for the world-space radii of the noise levels and the minimap rings.
const RANGES := {
	Level.VERY_CLOSE: 3.0,
	Level.CLOSE: 8.0,
	Level.FAR: 15.0,
}

# Ring radii in order, innermost first, for the sonar map.
func ring_distances() -> Array[float]:
	var out: Array[float] = []
	for level in [Level.VERY_CLOSE, Level.CLOSE, Level.FAR]:
		out.append(RANGES[level])
	return out

signal noise_made(position: Vector3, level: Level)

func make_noise(position: Vector3, level: Level) -> void:
	if level == Level.SILENT:
		return  # dead silent: nothing happens, nobody is notified

	noise_made.emit(position, level)

	# Notify every listener in range
	var radius: float = RANGES[level]
	for listener in get_tree().get_nodes_in_group("noise_listeners"):
		if listener.global_position.distance_to(position) <= radius:
			listener.hear_noise(position, level)
