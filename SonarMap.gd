extends Control
class_name SonarMap

@export var target: Node3D                       # whatever sits at the center of the map
@export_flags_3d_physics var scan_mask := 3      # layers 1 + 2 (walls + enemies)
@export var enemy_group := "enemy"
@export var ring_distances: Array[float] = [3.0, 8.0, 15.0]    # world units: very close, closer, far
@export var ring_pixels: Array[float] = [45.0, 80.0, 115.0]    # outer radius of each ring on screen
@export var scan_interval := 0.1

const DIRS := 8
var _cells: Array = []     # per direction: null or {"ring": int, "enemy": bool}
var _timer := 0.0
var alert := false         # true when something is in the very-close ring

func _ready() -> void:
	_cells.resize(DIRS)
	_cells.fill(null)

func _process(delta: float) -> void:
	_timer += delta
	if _timer >= scan_interval:
		_timer = 0.0
		_scan()
	queue_redraw()

func _scan() -> void:
	if target == null:
		return
	var space := target.get_world_3d().direct_space_state
	var origin := target.global_position + Vector3.UP * 0.5
	var max_d: float = ring_distances.back()
	alert = false
	for i in DIRS:
		var a := TAU * i / DIRS
		var dir := Vector3(sin(a), 0.0, -cos(a))     # i = 0 is north (-Z), going clockwise
		var q := PhysicsRayQueryParameters3D.create(origin, origin + dir * max_d, scan_mask)
		if target is CollisionObject3D:
			q.exclude = [target.get_rid()]
		var hit := space.intersect_ray(q)
		if hit.is_empty():
			_cells[i] = null
			continue
		var d := origin.distance_to(hit.position)
		var ring := 0
		while ring < ring_distances.size() - 1 and d > ring_distances[ring]:
			ring += 1
		_cells[i] = {"ring": ring, "enemy": hit.collider.is_in_group(enemy_group)}
		if ring == 0:
			alert = true

func _draw() -> void:
	var c := size / 2.0
	for i in DIRS:
		var a := TAU * i / DIRS
		for r in ring_pixels.size():
			var inner := 18.0 if r == 0 else ring_pixels[r - 1] + 3.0
			var col := Color(0.2, 0.8, 1.0, 0.12)                     # empty cell
			var cell = _cells[i]
			if cell != null and cell.ring == r:
				col = Color(1, 0.2, 0.2, 0.9) if cell.enemy else Color(0.2, 1.0, 0.6, 0.9)
			draw_colored_polygon(_wedge(c, a, inner, ring_pixels[r]), col)

	# proximity warning: pulsing red outline
	if alert:
		var pulse := 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.015)
		draw_arc(c, ring_pixels.back() + 6.0, 0.0, TAU, 64, Color(1, 0.1, 0.1, pulse), 3.0)

	# player arrow: rotates with the target, the map does not
	var heading := 0.0
	if target:
		var f := -target.global_transform.basis.z
		heading = atan2(f.x, -f.z)
	draw_set_transform(c, heading)
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, -12), Vector2(9, 10), Vector2(0, 5), Vector2(-9, 10)]), Color.WHITE)
	draw_set_transform(Vector2.ZERO, 0.0)

func _wedge(c: Vector2, a: float, r0: float, r1: float, steps := 6) -> PackedVector2Array:
	var half := TAU / DIRS / 2.0 - 0.04               # small gap between wedges
	var pts := PackedVector2Array()
	for s in steps + 1:
		var t := a - half + 2.0 * half * s / steps
		pts.append(c + Vector2(sin(t), -cos(t)) * r1)
	for s in range(steps, -1, -1):
		var t := a - half + 2.0 * half * s / steps
		pts.append(c + Vector2(sin(t), -cos(t)) * r0)
	return pts
