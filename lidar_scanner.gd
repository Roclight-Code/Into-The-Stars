extends Node3D

# --- Tweak these ---
@export var grid_width: int = 64     # beams across (change to try a different density)
@export var grid_height: int = 36    # beams down
@export var fov_vertical: float = 60.0
@export var max_range: float = 30.0
@export var scan_active: bool = false

@export var display: Control
@export var rover_body: CollisionObject3D

var _query := PhysicsRayQueryParameters3D.new()

func _ready() -> void:
	if rover_body:
		_query.exclude = [rover_body.get_rid()]  # beams ignore the rover itself

func toggle_scan() -> void:
	scan_active = not scan_active
	if not scan_active and display:
		display.clear_dots()

func _physics_process(_delta: float) -> void:
	if not scan_active or display == null:
		return

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
				positions.append(Vector2(u, v))
				brightness.append(1.0 - dist / max_range)  # close = bright

	display.set_dots(positions, brightness)
