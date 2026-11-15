extends CanvasLayer

@export var enabled := true

func _ready() -> void:
	_apply()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo \
			and event.keycode == KEY_F2:
		enabled = not enabled
		_apply()

func _apply() -> void:
	visible = enabled
	RenderingServer.global_shader_parameter_set("psx_enabled", 1.0 if enabled else 0.0)
