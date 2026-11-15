extends Node

const PSX_SHADER := preload("res://shaders/psx.gdshader")

func _ready() -> void:
	_convert(get_tree().current_scene)

func _convert(node: Node) -> void:
	if node.is_in_group("no_psx"):
		return  # skips this node and all of its children
	if node is MeshInstance3D and node.mesh:
		for i in node.mesh.get_surface_count():
			var m = node.get_active_material(i)
			if m is StandardMaterial3D:
				var sm := ShaderMaterial.new()
				sm.shader = PSX_SHADER
				sm.set_shader_parameter("albedo_tex", m.albedo_texture)
				sm.set_shader_parameter("tint", m.albedo_color)
				node.set_surface_override_material(i, sm)
	for child in node.get_children():
		_convert(child)
