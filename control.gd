extends Control
class_name control

@export var target: Node3D
@export_flags_3d_physics var scan_mask := 3
@export var enemy_group := "enemy"
@export var ring_distances: Array[float] = [3.0, 8.0, 15.0]
@export var ring_pixels: Array[float] = [45.0, 80.0, 115.0]
@export var scan_interval := 0.1

@export var frame_color := Color(0.96, 0.95, 0.92)
@export var glass_color := Color(0.72, 0.86, 0.96)
@export var wall_color := Color(0.9, 0.55, 0.2)
@export var enemy_color := Color(1.0, 0.15, 0.15)
@export var center_radius := 18.0
@export var bar_width := 3.0

@export var noise_color := Color(1.0, 0.85, 0.1)
@export var noise_duration := 1.0

const DIRS := 8
const OCT_K := 1.0823922   # 1 / cos(22.5°)

var _cells: Array = []
var _timer := 0.0
var alert := false
var _noises := {}  # Vector2i(ring, dir) -> seconds left

func _ready() -> void:
	_cells.resize(DIRS)
	_cells.fill(null)
	NoiseBus.noise_made.connect(_on_noise_made)


func _process(delta: float) -> void:
	_timer += delta
	if _timer >= scan_interval:
		_timer = 0.0
		_scan()
	for key in _noises.keys():
		_noises[key] -= delta
		if _noises[key] <= 0.0:
			_noises.erase(key)
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
		var dir := Vector3(sin(a), 0.0, -cos(a))
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
	var outer: float = ring_pixels.back()

	# window molding, drawn outside-in
	draw_colored_polygon(_oct(c, outer + 22.0), Color(0.62, 0.60, 0.56))
	draw_colored_polygon(_oct(c, outer + 19.0), frame_color)
	draw_colored_polygon(_oct(c, outer + 10.0), frame_color.darkened(0.12))
	draw_colored_polygon(_oct(c, outer + 7.0), frame_color)

	# glass
	draw_colored_polygon(_oct(c, outer), glass_color)

	# lit cells
	for i in DIRS:
		var cell = _cells[i]
		if cell == null:
			continue
		var r: int = cell.ring
		var inner := center_radius if r == 0 else ring_pixels[r - 1]
		var col := enemy_color if cell.enemy else wall_color
		draw_colored_polygon(_cell(c, TAU * i / DIRS, inner, ring_pixels[r]), col)

	# noise cells
	for key in _noises:
		var nr: int = key.x
		var ni: int = key.y
		var fade := clampf(_noises[key] / noise_duration, 0.0, 1.0)
		var n_inner := center_radius if nr == 0 else ring_pixels[nr - 1]
		var ncol := noise_color
		ncol.a = 0.35 + 0.5 * fade
		draw_colored_polygon(_cell(c, TAU * ni / DIRS, n_inner, ring_pixels[nr]), ncol)

	# window bars: ring outlines + 8 spokes
	for r in ring_pixels.size():
		_outline(c, ring_pixels[r])
	_outline(c, center_radius)
	for k in DIRS:
		var t := TAU * (k + 0.5) / DIRS
		var d := Vector2(sin(t), -cos(t))
		draw_line(c + d * center_radius * OCT_K, c + d * outer * OCT_K, frame_color, bar_width, true)

# exclamation marks
	for key in _noises:
		var er: int = key.x
		var ei: int = key.y
		var ea: float = TAU * ei / DIRS
		var e_inner: float = center_radius if er == 0 else ring_pixels[er - 1]
		var mid: float = (e_inner + ring_pixels[er]) * 0.5
		var p: Vector2 = c + Vector2(sin(ea), -cos(ea)) * mid
		draw_string(ThemeDB.fallback_font, p + Vector2(-10, 8), "!",
			HORIZONTAL_ALIGNMENT_CENTER, 20, 22, Color(0.6, 0.05, 0.05))

	# proximity warning: pulsing outline on the molding
	if alert:
		var pulse := 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.015)
		var pts := _oct(c, outer + 14.0)
		pts.append(pts[0])
		draw_polyline(pts, Color(1, 0.1, 0.1, pulse), 3.0, true)

	# player arrow: rotates with the target, the map does not
	var heading := 0.0
	if target:
		var f := -target.global_transform.basis.z
		heading = atan2(f.x, -f.z)
	draw_set_transform(c, heading)
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, -12), Vector2(9, 10), Vector2(0, 5), Vector2(-9, 10)]), Color(0.1, 0.15, 0.3))
	draw_set_transform(Vector2.ZERO, 0.0)

func _oct(c: Vector2, apothem: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for k in DIRS:
		var t := TAU * (k + 0.5) / DIRS
		pts.append(c + Vector2(sin(t), -cos(t)) * apothem * OCT_K)
	return pts

func _outline(c: Vector2, apothem: float) -> void:
	var pts := _oct(c, apothem)
	pts.append(pts[0])
	draw_polyline(pts, frame_color, bar_width, true)

func _cell(c: Vector2, a: float, r0: float, r1: float) -> PackedVector2Array:
	var t0 := a - TAU / DIRS / 2.0
	var t1 := a + TAU / DIRS / 2.0
	var v0 := Vector2(sin(t0), -cos(t0))
	var v1 := Vector2(sin(t1), -cos(t1))
	return PackedVector2Array([
		c + v0 * r1 * OCT_K, c + v1 * r1 * OCT_K,
		c + v1 * r0 * OCT_K, c + v0 * r0 * OCT_K])

func _on_noise_made(pos: Vector3, level) -> void:
	if target == null:
		return
	var offset := pos - target.global_position
	var d := offset.length()
	if d > NoiseBus.RANGES[level]: # If you’d rather show every noise on the map regardless, delete the if d > NoiseBus.RANGES[level] check. 
		return  # too far away to be heard
	var ring := -1
	for r in ring_distances.size():
		if d <= ring_distances[r]:
			ring = r
			break
	if ring == -1:
		return  # off the map
	var dir := posmod(roundi(atan2(offset.x, -offset.z) / (TAU / DIRS)), DIRS)
	_noises[Vector2i(ring, dir)] = noise_duration
