# map_baker.gd - run once from the editor (@tool script, or a button in an EditorScript)
@tool
extends EditorScript

const SPACING := 1.0  # one point per meter; raise to 2.0 for a coarser, lighter map

func _run():
	var root := get_scene()
	var points := PackedVector2Array()
	var seen := {}

	for node in root.find_children("*", "MeshInstance3D", true, false):
		if not node.is_in_group("walls"):
			continue
		var mesh: Mesh = node.mesh
		var xform: Transform3D = node.global_transform
		for surf in mesh.get_surface_count():
			var arrays := mesh.surface_get_arrays(surf)
			for v in arrays[Mesh.ARRAY_VERTEX]:
				var w := xform * v
				var key := Vector2i(round(w.x / SPACING), round(w.z / SPACING))
				if not seen.has(key):
					seen[key] = true
					points.append(Vector2(key.x * SPACING, key.y * SPACING))

	var res := WallPoints.new()   # a small custom Resource with one exported PackedVector2Array
	res.points = points
	ResourceSaver.save(res, "res://data/wall_points.tres")
	print("Baked ", points.size(), " points")

var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]

	# revealed wall points: dark dot with a light edge
	for p in _reveal_pts:
		var rel := (p - o) * px_per_unit
		if rel.length() <= pulse_r:
			var pos := c + rel
			draw_rect(Rect2(pos - Vector2(3, 3), Vector2(6, 6)), Color(1, 1, 1, 0.9 * reveal_alpha))
			draw_rect(Rect2(pos - Vector2(2, 2), Vector2(4, 4)), Color(0.02, 0.05, 0.25, reveal_alpha))
	# ...same dedupe-and-append code as before...
