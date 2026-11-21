extends Node3D

# --- Tweak these ---
@export var grid_width: int = 64     # beams across (change to try a different density)
@export var grid_height: int = 36    # beams down
@export var fov_vertical: float = 60.0
@export var max_range: float = 30.0

@export var display: Control
@export var rover_body: CollisionObject3D

@export var depth_falloff: float = 0.15       # higher = distance dims dots faster
@export_range(0.0, 1.0) var angle_shading: float = 0.65  # 0 = ignore surface angle, 1 = strong

@export var generator: Node3D
@export_flags_3d_physics var scan_mask := 5   # World + Enemies

@export_group("Performance")
## Rays fired per second. The scan rate follows from this and the grid size
## (64 x 36 = 2304 rays per scan, so 35000 is about 15 scans per second).
@export_range(5000, 140000, 1000) var rays_per_second := 35000

const _PRESETS := [140000, 70000, 35000, 17000]
var _preset := 2

var _accum := 0.0

var _query := PhysicsRayQueryParameters3D.new()

var _showing := false

func _ready() -> void:
	if rover_body:
		_query.exclude = [rover_body.get_rid()]
		_query.collision_mask = scan_mask

func setup(gen: Node3D, disp: Control) -> void:
	generator = gen
	display = disp
	if display:
		display.set_grid(grid_width, grid_height)
		display.clear_dots()

func _on_lidar_changed(on: bool) -> void:
	if not on and display:
		display.clear_dots()

func _physics_process(delta: float) -> void:
	if display == null or generator == null:
		return
	if not generator.lidar_active:
		if _showing:
			display.clear_dots()
			_showing = false
		return
	_accum += delta
	var interval := float(grid_width * grid_height) / float(rays_per_second)
	if _accum < interval:
		return
	_accum = 0.0

	var space := get_world_3d().direct_space_state
	var aspect := float(grid_width) / float(grid_height)
	var tan_half := tan(deg_to_rad(fov_vertical) * 0.5)
	var origin := global_position

	var positions := PackedVector2Array()
	var brightness := PackedFloat32Array()

	for y in grid_height:
		for x in grid_width:
			# Cell center in 0..1 screen space
			var u := (x + 0.5) / grid_width
			var v := (y + 0.5) / grid_height

			# Beam direction: fixed, same every frame, relative to the scanner
			var local_dir := Vector3(
				(u * 2.0 - 1.0) * tan_half * aspect,
				(1.0 - v * 2.0) * tan_half,
				-1.0
			).normalized()
			var dir := global_transform.basis * local_dir

			_query.from = origin
			_query.to = origin + dir * max_range
			var hit := space.intersect_ray(_query)

			if hit:
				var dist := origin.distance_to(hit.position)

				# 1) Depth: exponential falloff, so small distance changes are visible up close
				var depth_b := exp(-dist * depth_falloff)

				# 2) Surface angle: faces pointing at the camera are bright, grazing ones are dim
				var facing := absf(hit.normal.dot(-dir))
				var angle_b := lerpf(1.0 - angle_shading, 1.0, facing)

				positions.append(Vector2(u, v))
				brightness.append(depth_b * angle_b)

	display.set_dots(positions, brightness)
	_showing = true

func _unhandled_input(event: InputEvent) -> void: #This is just to see performance, we can delete this later
	if event is InputEventKey and event.pressed and event.keycode == KEY_F3:
		_preset = (_preset + 1) % _PRESETS.size()
		rays_per_second = _PRESETS[_preset]
		print("Lidar rays per second: ", rays_per_second)
