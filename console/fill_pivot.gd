extends Node3D

@export var generator: Node3D
@export var fill_pivot: Node3D
@export var fill_mesh: MeshInstance3D

const READY_COLOR := Color(1.0, 0.85, 0.1)       # yellow: on and usable
const OFF_READY_COLOR := Color(1.0, 0.5, 0.0)    # orange: switched off, but safe to turn back on
const BLOCKED_COLOR := Color(1.0, 0.1, 0.1)      # red: locked out (below 40% after a full drain)

var _mat := StandardMaterial3D.new()

func _ready() -> void:
	_mat.emission_enabled = true
	fill_mesh.material_override = _mat
	generator.energy_changed.connect(func(_v): _refresh())
	generator.lockout_changed.connect(func(_v): _refresh())
	generator.power_changed.connect(func(_v): _refresh())
	_refresh()

func _refresh() -> void:
	fill_pivot.scale.x = maxf(generator.energy / generator.max_energy, 0.001)

	var c: Color
	if generator.locked:
		c = BLOCKED_COLOR
	elif generator.is_on:
		c = READY_COLOR
	else:
		c = OFF_READY_COLOR

	_mat.albedo_color = c
	_mat.emission = c
