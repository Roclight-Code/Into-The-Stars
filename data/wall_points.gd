# wall_points.gd
class_name WallPoints
extends Resource
@export var points: PackedVector2Array

var wall_points: PackedVector2Array = preload("res://data/wall_points.tres").points

func get_revealable_walls() -> Array:
	var origin := Vector2(scan_origin.x, scan_origin.z)
	var r2 := scan_radius * scan_radius
	var out := []
	for p in wall_points:
		if p.distance_squared_to(origin) <= r2:
			out.append(p)
	return out
