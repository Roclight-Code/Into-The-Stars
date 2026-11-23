extends Node3D

@onready var screen: MeshInstance3D = $Screen
@onready var viewport: SubViewport = $SubViewport

var screen_material: StandardMaterial3D

func _ready() -> void:
	screen_material = StandardMaterial3D.new()
	var tex := viewport.get_texture()
	screen_material.albedo_texture = tex
	screen_material.emission_enabled = true
	screen_material.emission_texture = tex
	screen_material.emission_energy_multiplier = 1.0
	screen.material_override = screen_material
